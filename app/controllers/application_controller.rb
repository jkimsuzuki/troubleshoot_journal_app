class ApplicationController < ActionController::Base
  include Authentication

  private
    def block_demo_writes
      return unless Current.user&.demo?

      redirect_back fallback_location: root_path, alert: "This is a read-only demo account."
    end
end
