class Issue < ApplicationRecord
  belongs_to :project
  validates :title, presence: true
  validates :project_name, presence: true
  validates :status, presence: true
end
