class Issue < ApplicationRecord
  belongs_to :projects
  validates :title, presence: true
  validates :project_name, presence: true
  validates :status, presence: true
end
