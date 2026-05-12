class Issue < ApplicationRecord
  validates :title, presence: true
  validates :project_name, presence: true
  validates :status, presence: true
end
