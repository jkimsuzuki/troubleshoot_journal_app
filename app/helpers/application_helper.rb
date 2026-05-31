module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? "active-nav" : nil
  end

  def status_label(status)
    status == "Investigating" ? "Active" : status
  end
end
