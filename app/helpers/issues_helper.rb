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
end
