json.extract! issue, :id, :title, :project_name, :status, :error_message, :stack_trace, :steps_to_reproduce, :what_i_checked, :root_cause, :fix, :prevention, :interview_summary, :created_at, :updated_at
json.url issue_url(issue, format: :json)
