class Issue < ApplicationRecord
  belongs_to :project

  has_many :issue_tags, dependent: :destroy
  has_many :tags, through: :issue_tags

  validates :title, presence: true
  validates :project_id, presence: true
  validates :status, presence: true
  validates :severity, presence: true
end
