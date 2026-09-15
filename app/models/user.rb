class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :issues, through: :projects

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  DEMO_EMAIL = "demo@signaldesk.foo"

  def demo?
    email_address == DEMO_EMAIL
  end
end
