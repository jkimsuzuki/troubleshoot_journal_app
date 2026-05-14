json.extract! project, :id, :name, :description, :status, :created_at, :updated_at
json.url project_url(project, format: :json)
