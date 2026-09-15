class Project < ApplicationRecord
  belongs_to :user
  has_many :issues, dependent: :destroy
end
