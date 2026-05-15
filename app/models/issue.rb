class Issue < ApplicationRecord
  belongs_to :project
  validates :title, presence: true
  validates :project_id, presence: true
  validates :status, presence: true
end
