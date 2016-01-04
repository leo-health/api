class Form < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :patient
  belongs_to :submitted_by, class_name: "User"
  belongs_to :completed_by, class_name: "User"

  validates :title, presence: true
  validates :patient, presence: true
  validates :submitted_by, presence: true
end
