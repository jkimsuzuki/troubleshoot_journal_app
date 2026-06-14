class MetricsController < ApplicationController
  skip_before_action :require_authentication

  def show
    metrics = []
    metrics << "# HELP signaldesk_issues_total Total number of issues"
    metrics << "# TYPE signaldesk_issues_total gauge"
    metrics << "signaldesk_issues_total #{Issue.count}"

    metrics << "# HELP signaldesk_projects_total Total number of projects"
    metrics << "# TYPE signaldesk_projects_total gauge"
    metrics << "signaldesk_projects_total #{Project.count}"

    metrics << "# HELP signaldesk_tags_total Total number of tags"
    metrics << "# TYPE signaldesk_tags_total gauge"
    metrics << "signaldesk_tags_total #{Tag.count}"

    metrics << "# HELP signaldesk_users_total Total number of users"
    metrics << "# TYPE signaldesk_users_total gauge"
    metrics << "signaldesk_users_total #{User.count}"

    metrics << "signaldesk_open_issues #{Issue.where(status: 'open').count}"
    metrics << "signaldesk_resolved_issues #{Issue.where(status: 'resolved').count}"
    metrics << "signaldesk_investigating_issues #{Issue.where(status: 'investigating').count}"

    render plain: metrics.join("\n"), content_type: "text/plain"
  end
end
