class MetricsController < ApplicationController
  skip_before_action :require_authentication

  def show
    metrics = []

    metrics << "# HELP signaldesk_pending_issues Pending issues"
    metrics << "# TYPE signaldesk_pending_issues gauge"
    metrics << "signaldesk_pending_issues #{Issue.where(status: 'Pending').count}"


    metrics << "# HELP signaldesk_investigating_issues Investigating issues"
    metrics << "# TYPE signaldesk_investigating_issues gauge"
    metrics << "signaldesk_investigating_issues #{Issue.where(status: 'Investigating').count}"

    metrics << "# HELP signaldesk_backlog Total unresolved incidents"
    metrics << "# TYPE signaldesk_backlog gauge"
    metrics << "signaldesk_backlog #{Issue.where(status: [ 'Pending', 'Investigating' ]).count}"

    metrics << "# HELP signaldesk_created_today Issues created today"
    metrics << "# TYPE signaldesk_created_today gauge"
    metrics << "signaldesk_created_today #{Issue.where(created_at: Time.zone.today.all_day).count}"

    oldest_open = Issue.where(status: [ "Pending", "Investigating" ])
                   .minimum(:created_at)

    oldest_days =
      oldest_open ? ((Time.current - oldest_open) / 1.day).to_i : 0

    metrics << "# HELP signaldesk_oldest_open_incident_days Oldest open incident age"
    metrics << "# TYPE signaldesk_oldest_open_incident_days gauge"
    metrics << "signaldesk_oldest_open_incident_days #{oldest_days}"

    metrics << "# HELP signaldesk_incidents_over_7_days Open incidents older than 7 days"
    metrics << "# TYPE signaldesk_incidents_over_7_days gauge"
    metrics << "signaldesk_incidents_over_7_days #{Issue.where(status: [ 'Pending', 'Investigating' ])
                                                      .where('created_at < ?', 7.days.ago)
                                                      .count}"

    root_cause_coverage =
      if Issue.count.zero?
        0
      else
        (Issue.where.not(root_cause: [ nil, "" ]).count.to_f /
         Issue.count * 100).round
      end

    metrics << "# HELP signaldesk_root_cause_coverage Root cause coverage percentage"
    metrics << "# TYPE signaldesk_root_cause_coverage gauge"
    metrics << "signaldesk_root_cause_coverage #{root_cause_coverage}"

    fix_coverage =
  if Issue.count.zero?
    0
  else
    (Issue.where.not(fix: [ nil, "" ]).count.to_f /
     Issue.count * 100).round
  end

    metrics << "# HELP signaldesk_fix_coverage Fix coverage percentage"
    metrics << "# TYPE signaldesk_fix_coverage gauge"
    metrics << "signaldesk_fix_coverage #{fix_coverage}"

    prevention_coverage =
  if Issue.count.zero?
    0
  else
    (Issue.where.not(prevention: [ nil, "" ]).count.to_f /
     Issue.count * 100).round
  end

    metrics << "# HELP signaldesk_prevention_coverage Prevention coverage percentage"
    metrics << "# TYPE signaldesk_prevention_coverage gauge"
    metrics << "signaldesk_prevention_coverage #{prevention_coverage}"

    render plain: metrics.join("\n"), content_type: "text/plain"
  end
end
