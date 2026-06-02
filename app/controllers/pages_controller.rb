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
  @query = params[:query]
  @project_id = params[:project_id]
  @status = params[:status]

  @recent_issues = Issue.includes(:project).order(updated_at: :desc)

  if @query.present?
    @recent_issues = @recent_issues.where(
      "title LIKE :query OR root_cause LIKE :query OR fix LIKE :query OR error_message LIKE :query",
      query: "%#{@query}%"
    )
  end

  if @project_id.present?
    @recent_issues = @recent_issues.where(project_id: @project_id)
  end

  if @status.present?
    @recent_issues = @recent_issues.where(status: @status)
  end

  @grouped_issues = @recent_issues.group_by { |issue| issue.updated_at.to_date }
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
