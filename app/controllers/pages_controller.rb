class PagesController < ApplicationController
  def dashboard
    @total_issues = Issue.count
    @resolved_issues = Issue.where(status: "Resolved").count
    @investigating_issues = Issue.where(status: "Investigating").count
    @pending_issues = Issue.where(status: "Pending").count

    @recent_issues = Issue.order(updated_at: :desc).limit(5)
    @projects = Project.all
    @tags = Tag.all

    @recent_issues = Issue.order(updated_at: :desc).limit(8)
    @active_issues =
      Issue.where(status: "Investigating").or(
        Issue.where(status: "Pending")
        )

    @critical_issues = Issue.where(severity: "Critical").count
  end

  def timeline
    @recent_issues = Issue.order(updated_at: :desc).limit(10)
  end

  def reports
    @total_issues = Issue.count
    @resolved_issues = Issue.where(status: "Resolved").count
    @investigating_issues = Issue.where(status: "Investigating").count
    @pending_issues = Issue.where(status: "Pending").count

    @low_severity = Issue.where(severity: "Low").count
    @medium_severity = Issue.where(severity: "Medium").count
    @high_severity = Issue.where(severity: "High").count
    @critical_severity = Issue.where(severity: "Critical").count

    @projects = Project.all
    @tags = Tag.all
  end

  def search
    @query = params[:query]

    @issues =
      if @query.present?
        Issue.where(
          "title LIKE :query OR error_message LIKE :query OR root_cause LIKE :query OR fix LIKE :query",
          query: "%#{@query}%"
        )
      else
        Issue.none
      end
  end

  def tags
  end
end
