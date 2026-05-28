class PagesController < ApplicationController
  def timeline
    @recent_issues = Issue.order(updated_at: :desc).limit(10)
  end

  def reports
    @total_issues = Issue.count
  @resolved_issues = Issue.where(status: "Resolved").count
    @investigating_issues = Issue.where(status: "Investigating").count
    @pending_issues = Issue.where(status: "Pending").count

    @projects = Project.all
    @tags = Tag.all
  end

  def search
  end

  def tags
  end
end
