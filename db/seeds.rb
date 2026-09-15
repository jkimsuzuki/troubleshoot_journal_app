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

demo_user = User.find_or_create_by!(email_address: "demo@signaldesk.foo") do |user|
  user.password = ENV.fetch("DEMO_PASSWORD", "SignalDeskDemo!2026")
end

demo_project = demo_user.projects.find_or_create_by!(name: "Sample E-commerce App") do |project|
  project.description = "A demo project showing what the Troubleshooting Journal tracks."
  project.status = "Active"
end

[
  {
    title: "Checkout fails with nil cart total",
    status: "Resolved",
    severity: "High",
    error_message: "NoMethodError: undefined method `to_money' for nil:NilClass",
    stack_trace: "app/models/cart.rb:42:in `total'",
    steps_to_reproduce: "Add an out-of-stock item to cart, then attempt checkout.",
    what_i_checked: "Logs, cart serializer, inventory sync job",
    root_cause: "Inventory sync job removed line items without recalculating the cart total.",
    fix: "Recalculate cart total whenever line items change.",
    prevention: "Added a model callback and a regression test.",
    interview_summary: "Traced a silent nil propagation through three layers before finding the sync job as the source.",
    tags: [ "Rails", "Database" ]
  },
  {
    title: "Intermittent 502s under load",
    status: "Investigating",
    severity: "Critical",
    error_message: "Gateway timeout after 30s",
    stack_trace: "N/A - infrastructure level",
    steps_to_reproduce: "Load test at 200 req/s sustained for 5 minutes.",
    what_i_checked: "Puma thread pool, DB connection pool, Grafana dashboards",
    root_cause: "Still investigating - suspect DB connection pool exhaustion.",
    interview_summary: "Used the embedded observability dashboard to correlate latency spikes with connection pool saturation.",
    tags: [ "Deployment" ]
  },
  {
    title: "CSS grid breaks on Safari",
    status: "Resolved",
    severity: "Low",
    error_message: "Layout collapses on Safari 17",
    stack_trace: "N/A",
    steps_to_reproduce: "Open dashboard on Safari, resize window below 900px.",
    what_i_checked: "CSS grid-template-columns, browser devtools",
    root_cause: "Safari's implementation of minmax() differs from Chrome's for this grid setup.",
    fix: "Replaced minmax() with explicit fr units.",
    prevention: "Added a cross-browser visual regression check.",
    interview_summary: "Good reminder to test layout-critical CSS in Safari, not just Chrome.",
    tags: [ "CSS", "Testing" ]
  }
].each do |attrs|
  tag_names = attrs.delete(:tags)
  issue = demo_project.issues.find_or_initialize_by(title: attrs[:title])
  issue.assign_attributes(attrs)
  issue.tags = Tag.where(name: tag_names)
  issue.save!
end
