class Form < ActiveRecord::Base
  acts_as_paranoid
  mount_uploader :image, FormUploader

  belongs_to :patient
  belongs_to :submitted_by, class_name: "User"
  belongs_to :completed_by, class_name: "User"

  validates :title, presence: true
  validates :patient, presence: true
  validates :submitted_by, presence: true
  validates_integrity_of  :image
  validates_processing_of :image
end
