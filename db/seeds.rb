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
