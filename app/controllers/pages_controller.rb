class PagesController < ApplicationController
  def dashboard
    status_counts = Current.user.issues.group(:status).count
    @total_issues = status_counts.values.sum
    @resolved_issues = status_counts["Resolved"].to_i
    @investigating_issues = status_counts["Investigating"].to_i
    @pending_issues = status_counts["Pending"].to_i

    @projects = Current.user.projects
    @tags = Tag.all

    @recent_issues = Current.user.issues.order(updated_at: :desc).limit(8)
    @active_issues = Current.user.issues.where(status: [ "Investigating", "Pending" ])

    @critical_issues = Current.user.issues.where(severity: "Critical").count
  end

  def timeline
    @query = params[:query]
    @project_id = params[:project_id]
    @status = params[:status]

    @recent_issues = Current.user.issues.includes(:project).order(updated_at: :desc)

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
    status_counts = Current.user.issues.group(:status).count
    @total_issues = status_counts.values.sum
    @resolved_issues = status_counts["Resolved"].to_i
    @investigating_issues = status_counts["Investigating"].to_i
    @pending_issues = status_counts["Pending"].to_i

    severity_counts = Current.user.issues.group(:severity).count
    @low_severity = severity_counts["Low"].to_i
    @medium_severity = severity_counts["Medium"].to_i
    @high_severity = severity_counts["High"].to_i
    @critical_severity = severity_counts["Critical"].to_i

    @projects = Current.user.projects
    @tags = Tag.all

    @resolution_rate =
  @total_issues.positive? ? ((@resolved_issues.to_f / @total_issues) * 100).round : 0

    @projects_report = Current.user.projects

    @tag_counts = Current.user.issues.joins(:tags).group("tags.id").count
    @top_tags = Tag.all.sort_by { |tag| -@tag_counts.fetch(tag.id, 0) }.first(6)
    @max_tag_count = [ @tag_counts.values.max.to_i, 1 ].max
  end

  def search
    @query = params[:query]
    @status = params[:status]
    @project_id = params[:project_id]
    @tag_id = params[:tag_id]

    @issues = Current.user.issues.includes(:project, :tags)

    if @query.present?
      @issues = @issues.where(
        "title LIKE :query OR error_message LIKE :query OR root_cause LIKE :query OR fix LIKE :query OR prevention LIKE :query OR interview_summary LIKE :query",
        query: "%#{@query}%"
      )
    else
      @issues = Current.user.issues.none
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
