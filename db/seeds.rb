# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
[ "Rails", "Database", "Git", "CSS", "Routing", "Testing", "Deployment" ].each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end

demo_user = User.find_or_create_by!(email_address: User::DEMO_EMAIL) do |user|
  user.password = ENV.fetch("DEMO_PASSWORD", "SignalDeskDemo!2026")
end

# The demo account is reset to this fixed dataset on every boot, so stale
# entries never pile up and it never carries anything a visitor added.
demo_user.projects.destroy_all

demo_projects = {
  checkout: demo_user.projects.create!(
    name: "Storefront Checkout (Rails + Sidekiq)",
    description: "Cart, discounts, and order placement for the storefront.",
    status: "Active",
    created_at: 70.days.ago
  ),
  admin: demo_user.projects.create!(
    name: "Admin Ops Dashboard",
    description: "Internal tooling for support and ops to manage orders and inventory.",
    status: "Active",
    created_at: 58.days.ago
  ),
  api: demo_user.projects.create!(
    name: "GraphQL Storefront API",
    description: "Public GraphQL API consumed by partner integrations.",
    status: "Completed",
    created_at: 90.days.ago
  )
}

[
  {
    project: :checkout,
    title: "Checkout fails with nil cart total",
    status: "Resolved",
    severity: "High",
    error_message: "NoMethodError: undefined method `to_money' for nil:NilClass",
    stack_trace: "app/models/cart.rb:42:in `total'\napp/controllers/checkouts_controller.rb:18:in `create'",
    steps_to_reproduce: "Add an out-of-stock item to the cart, then attempt checkout.",
    what_i_checked: "Logs, cart serializer, inventory sync job",
    root_cause: "The inventory sync job removed line items without recalculating the cart total, leaving it nil.",
    fix: "Recalculate cart total in a model callback whenever line items change.",
    prevention: "Added a regression test covering cart total after item removal.",
    interview_summary: "Traced a silent nil propagation through three layers before finding the sync job as the source. Reinforced why I favor computed totals over cached ones that can drift.",
    tags: [ "Rails", "Database" ],
    created_at: 61.days.ago,
    resolved_after: 2.days
  },
  {
    project: :checkout,
    title: "Duplicate orders created from payment webhook retries",
    status: "Resolved",
    severity: "Critical",
    error_message: "Two Order records created for the same payment_intent_id",
    stack_trace: "app/jobs/payment_webhook_job.rb:15:in `perform'",
    steps_to_reproduce: "Simulate the payment provider retrying a webhook delivery after a slow 200 response.",
    what_i_checked: "Webhook logs, Sidekiq retry history, orders table for duplicate payment_intent_id values",
    root_cause: "The webhook handler wasn't idempotent — a retry within the ack window created a second order instead of recognizing the payment had already been processed.",
    fix: "Added a unique index on orders.payment_intent_id and made the job upsert instead of insert.",
    prevention: "Documented idempotency as a requirement for every webhook handler and added a shared job base class that enforces it.",
    interview_summary: "This one taught me to design webhook handlers assuming at-least-once delivery from day one, not retrofit idempotency after an incident.",
    tags: [ "Rails", "Database", "Deployment" ],
    created_at: 49.days.ago,
    resolved_after: 3.days
  },
  {
    project: :checkout,
    title: "Discount code validation race condition allows over-redemption",
    status: "Resolved",
    severity: "Medium",
    error_message: "Usage count for a limited discount code exceeded its max_redemptions",
    stack_trace: "app/models/discount_code.rb:31:in `redeem!'",
    steps_to_reproduce: "Fire two concurrent checkout requests using the last remaining redemption of a limited code.",
    what_i_checked: "DB logs for the discount_codes table, request timing in Grafana",
    root_cause: "Redemption count was read-then-written without a row lock, so two concurrent requests both read the same count before either wrote back.",
    fix: "Wrapped redemption in a `with_lock` transaction to serialize concurrent redeems.",
    prevention: "Added a test that fires concurrent redemption attempts against the same code.",
    interview_summary: "Good concrete example of a check-then-act race condition and why row-level locking beats an application-level mutex for this kind of state.",
    tags: [ "Rails", "Database", "Testing" ],
    created_at: 33.days.ago,
    resolved_after: 1.day
  },
  {
    project: :checkout,
    title: "Reverted pricing bug came back after a bad merge",
    status: "Resolved",
    severity: "Medium",
    error_message: "10% discount was applying twice again on bundle purchases",
    stack_trace: "app/models/pricing_calculator.rb:19:in `apply_discounts'",
    steps_to_reproduce: "Add a bundle item with an active discount to the cart and check the final price.",
    what_i_checked: "git blame on pricing_calculator.rb, git log for the original fix commit",
    root_cause: "A feature branch was cut before the original fix landed on main, then merged back later and silently reintroduced the old code during a conflict resolution.",
    fix: "Reapplied the fix and added a regression test so it can't regress silently again.",
    prevention: "Started requiring a changelog note on any PR that resolves a merge conflict touching pricing logic.",
    interview_summary: "Good lesson in why regression tests matter more than commit history — git blame told me what happened, but only a test could have stopped it from happening again.",
    tags: [ "Git", "Testing" ],
    created_at: 76.days.ago,
    resolved_after: 1.day
  },
  {
    project: :checkout,
    title: "Checkout memory usage climbs under sustained peak load",
    status: "Investigating",
    severity: "Critical",
    error_message: "Puma workers restarted repeatedly by the OOM killer during load test",
    stack_trace: "N/A - infrastructure level",
    steps_to_reproduce: "Run a sustained load test at 200 req/s against /checkout for 10 minutes.",
    what_i_checked: "Puma worker memory over time in Grafana, GC stats, object allocation in a memory profiler",
    root_cause: "Still narrowing it down — current suspicion is that a discount-lookup query is loading and memoizing more records per request than necessary under high cart-item counts.",
    interview_summary: "Using the embedded observability dashboard to correlate memory growth with request patterns rather than guessing.",
    tags: [ "Rails", "Deployment" ],
    created_at: 6.days.ago
  },
  {
    project: :admin,
    title: "Order list page times out with N+1 queries",
    status: "Resolved",
    severity: "Medium",
    error_message: "Request timeout after 30s on /admin/orders with 500+ orders",
    stack_trace: "app/views/admin/orders/index.html.erb:22",
    steps_to_reproduce: "Load /admin/orders on an account with several hundred orders, each with multiple line items.",
    what_i_checked: "bullet gem output, rack-mini-profiler, query counts in the logs",
    root_cause: "The order list view was calling order.line_items.count and order.customer.name in a loop with no eager loading — over 1,000 queries per page load.",
    fix: "Added includes(:customer, :line_items) to the controller query and a counter cache for line item counts.",
    prevention: "Added the bullet gem to CI so future N+1s fail the build instead of shipping.",
    interview_summary: "Classic N+1, but the useful part was setting up bullet in CI so this class of bug can't come back unnoticed.",
    tags: [ "Rails", "Database" ],
    created_at: 44.days.ago,
    resolved_after: 1.day
  },
  {
    project: :admin,
    title: "CSV export times out for large date ranges",
    status: "Resolved",
    severity: "Medium",
    error_message: "Gateway timeout when exporting a 12-month order range",
    stack_trace: "app/controllers/admin/exports_controller.rb:9:in `create'",
    steps_to_reproduce: "Request a CSV export covering a 12-month date range on a busy store.",
    what_i_checked: "Request duration in logs, memory usage during export, row counts",
    root_cause: "The export built the entire CSV in memory synchronously inside the request instead of streaming it.",
    fix: "Moved the export to a background job that streams rows to CSV and emails a download link when done.",
    prevention: "Added a size threshold that routes small exports synchronously and large ones to the background job automatically.",
    interview_summary: "Reinforced a rule of thumb I now apply by default: anything that scales with user data size doesn't belong in the request/response cycle.",
    tags: [ "Rails", "Deployment" ],
    created_at: 27.days.ago,
    resolved_after: 2.days
  },
  {
    project: :admin,
    title: "Admin order routes 404 after adding a status constraint",
    status: "Resolved",
    severity: "Low",
    error_message: "ActionController::RoutingError on /admin/orders/12345/refund",
    stack_trace: "config/routes.rb:14",
    steps_to_reproduce: "Visit the refund page for an order whose id doesn't match the new numeric-only constraint.",
    what_i_checked: "config/routes.rb, the constraint regex, server logs for the 404",
    root_cause: "A route constraint added to disambiguate order ids from a new short-code format was too strict and excluded legitimate older numeric ids with leading zeros.",
    fix: "Loosened the constraint regex and added a test covering both id formats.",
    prevention: "Added a routing spec that exercises every constrained route with boundary-case ids.",
    interview_summary: "Reminder that route constraints are easy to get subtly wrong, and routing specs catch it faster than clicking through the UI does.",
    tags: [ "Routing", "Testing" ],
    created_at: 15.days.ago,
    resolved_after: 1.day
  },
  {
    project: :admin,
    title: "Order table columns overlap on narrow browser windows",
    status: "Resolved",
    severity: "Low",
    error_message: "Table columns overlap below 1024px",
    stack_trace: "N/A",
    steps_to_reproduce: "Open /admin/orders and narrow the browser window below 1024px.",
    what_i_checked: "Table CSS grid definitions, existing responsive breakpoints",
    root_cause: "The orders table used fixed pixel column widths that didn't account for the admin sidebar's own responsive breakpoint.",
    fix: "Switched to a responsive grid with a horizontal scroll container below the sidebar's breakpoint.",
    prevention: "Added the admin layout to the visual regression check that already covered the storefront.",
    interview_summary: "Small fix, but a good reminder to test internal tools at the same range of viewport widths as customer-facing pages.",
    tags: [ "CSS" ],
    created_at: 40.days.ago,
    resolved_after: 1.day
  },
  {
    project: :admin,
    title: "Dashboard shows stale inventory counts after Redis failover",
    status: "Pending",
    severity: "High",
    error_message: "Inventory counts on the dashboard lag real values by several minutes after a Redis failover",
    stack_trace: "N/A - caching layer",
    steps_to_reproduce: "Trigger a Redis failover in staging, then compare cached inventory counts against the database.",
    what_i_checked: "Cache TTLs, failover logs — haven't started root-causing yet",
    root_cause: nil,
    interview_summary: "Queued behind the checkout memory investigation — next up once that's resolved.",
    tags: [ "Deployment" ],
    created_at: 3.days.ago
  },
  {
    project: :api,
    title: "N+1 query in GraphQL product variants resolver",
    status: "Resolved",
    severity: "Medium",
    error_message: "P99 latency on the products query spiked for carts with many variants",
    stack_trace: "app/graphql/resolvers/product_variants_resolver.rb:11",
    steps_to_reproduce: "Query 50 products with 10+ variants each through the GraphQL API in a single request.",
    what_i_checked: "GraphQL query complexity logs, database query counts per request",
    root_cause: "Each product resolved its variants with a separate query instead of using a batched loader.",
    fix: "Switched the resolver to GraphQL::Batch to load variants for all requested products in one query.",
    prevention: "Added a query-count assertion to the resolver's test so a future N+1 fails CI.",
    interview_summary: "Good example of why GraphQL needs batching discipline that a REST endpoint doesn't — one client query can fan out into many resolver calls.",
    tags: [ "Rails", "Database", "Testing" ],
    created_at: 84.days.ago,
    resolved_after: 2.days
  },
  {
    project: :api,
    title: "Removing a deprecated field broke a partner integration",
    status: "Resolved",
    severity: "Critical",
    error_message: "Partner's nightly sync started failing with 'Cannot query field imageUrl on type Product'",
    stack_trace: "N/A - schema change",
    steps_to_reproduce: "Deploy the schema change removing Product.imageUrl in favor of Product.images, then run the partner's existing query.",
    what_i_checked: "API access logs to confirm which partners were still using the deprecated field",
    root_cause: "The field was removed on the planned deprecation date without checking whether any consumers were still using it.",
    fix: "Restored the field temporarily and reached out to the partner with a migration deadline.",
    prevention: "Added a query to check for field usage against real traffic before any deprecated field is removed, not just before it's marked deprecated.",
    interview_summary: "Learned the hard way that a deprecation calendar isn't a substitute for checking real usage data before removal.",
    tags: [ "Deployment", "Testing" ],
    created_at: 20.days.ago,
    resolved_after: 1.day
  },
  {
    project: :api,
    title: "Webhook signature verification rejected valid requests after key rotation",
    status: "Resolved",
    severity: "High",
    error_message: "401 Unauthorized: invalid webhook signature",
    stack_trace: "app/controllers/api/webhooks_controller.rb:8:in `verify_signature!'",
    steps_to_reproduce: "Rotate the webhook signing secret, then send a webhook signed with the new secret.",
    what_i_checked: "Signing secret in the credentials store, deploy timing, webhook delivery logs",
    root_cause: "The old and new secrets weren't accepted simultaneously during rotation, so any webhook signed and queued before the deploy finished failed verification after it completed.",
    fix: "Verified signatures against both the current and previous secret for a rotation grace period.",
    prevention: "Wrote a runbook for secret rotation that requires a dual-accept window for anything with in-flight requests.",
    interview_summary: "This showed me that secret rotation isn't just a config change — it's a distributed systems problem the moment there's anything in flight.",
    tags: [ "Rails", "Deployment" ],
    created_at: 8.days.ago,
    resolved_after: 1.day
  },
  {
    project: :api,
    title: "Pagination cursor breaks when combined with a filter",
    status: "Resolved",
    severity: "Low",
    error_message: "Second page of a filtered products query returns items from page one",
    stack_trace: "app/graphql/resolvers/products_resolver.rb:27",
    steps_to_reproduce: "Query products with a status filter and a cursor from a previous filtered page.",
    what_i_checked: "Cursor encoding logic, resolver test coverage for filtered pagination",
    root_cause: "The cursor encoded only the record's position, not the filter that produced it, so it was reused against an inconsistent result set.",
    fix: "Encoded the filter parameters into the cursor and validated they match on decode.",
    prevention: "Added test coverage for pagination combined with every supported filter.",
    interview_summary: "Small bug, useful reminder that a cursor is only meaningful relative to the exact query that produced it.",
    tags: [ "Rails", "Testing" ],
    created_at: 12.days.ago,
    resolved_after: 1.day
  }
].each do |attrs|
  attrs = attrs.dup
  project = demo_projects.fetch(attrs.delete(:project))
  tag_names = attrs.delete(:tags)
  created_at = attrs.delete(:created_at)
  resolved_after = attrs.delete(:resolved_after)

  issue = project.issues.create!(attrs.merge(created_at: created_at))
  issue.tags = Tag.where(name: tag_names)
  issue.update_column(:updated_at, resolved_after ? created_at + resolved_after : created_at)
end
