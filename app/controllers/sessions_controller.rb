class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create demo ]
  rate_limit to: 10, within: 3.minutes, only: %i[ create demo ], with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def demo
    start_new_session_for User.find_by!(email_address: User::DEMO_EMAIL)
    redirect_to root_url, notice: "You're viewing a read-only demo account."
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
