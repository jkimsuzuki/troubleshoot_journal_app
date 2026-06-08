class ApplicationController < ActionController::Base
  before_action :require_basic_auth, if: -> { Rails.env.production? }

  private

  def require_basic_auth
    authenticate_or_request_with_http_basic("Troubleshooting Journal") do |username, password|
      username == ENV["APP_USERNAME"] &&
        password == ENV["APP_PASSWORD"]
    end
  end
end
