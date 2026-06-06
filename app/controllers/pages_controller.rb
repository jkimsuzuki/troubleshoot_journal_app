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

    @resolution_rate =
  @total_issues.positive? ? ((@resolved_issues.to_f / @total_issues) * 100).round : 0

    @projects_report = Project.all

    @top_tags =
      Tag.left_joins(:issues)
         .group(:id)
         .order("COUNT(issues.id) DESC")
         .limit(6)

    @max_tag_count =
      @top_tags.map { |tag| tag.issues.count }.max || 1
  end

  def search
  @query = params[:query]
  @status = params[:status]
  @project_id = params[:project_id]
  @tag_id = params[:tag_id]

  @issues = Issue.includes(:project, :tags)

  if @query.present?
    @issues = @issues.where(
      "title LIKE :query OR error_message LIKE :query OR root_cause LIKE :query OR fix LIKE :query OR prevention LIKE :query OR interview_summary LIKE :query",
      query: "%#{@query}%"
    )
  else
    @issues = Issue.none
  end

  if @status.present?
    @issues = @issues.where(status: @status)
  end

  if @project_id.present?
    @issues = @issues.where(project_id: @project_id)
  end

  if @tag_id.present?
    @issues = @issues.joins(:tags).where(tags: { id: @tag_id })
  end
end

  def tags
  end
end
