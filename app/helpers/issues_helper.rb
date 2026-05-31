module IssuesHelper
  def status_badge_class(status)
    case status
    when "Resolved"
      "status-badge status-resolved"
    when "Investigating"
      "status-badge status-investigating"
    when "Pending"
      "status-badge status-pending"
    else
      "status-badge"
    end
  end

  def formatted_date(date)
    date.strftime("%B %d, %Y")
  end
end

def severity_badge_class(severity)
  case severity
  when "Critical"
    "severity-badge severity-critical"
  when "High"
    "severity-badge severity-high"
  when "Medium"
    "severity-badge severity-medium"
  when "Low"
    "severity-badge severity-low"
  else
    "severity-badge"
  end

  def status_label(status)
    status == "Investigating" ? "Active" : status
  end
end
