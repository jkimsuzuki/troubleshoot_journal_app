class PagesController < ApplicationController
  def timeline
    @recent_issues = Issue.order(updated_at: :desc).limit(10)
  end

  def reports
  end

  def search
  end

  def tags
  end
end
