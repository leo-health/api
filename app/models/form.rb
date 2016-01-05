class Form < ActiveRecord::Base
  acts_as_paranoid
  mount_uploader :image, FormUploader

  before_validation :set_form_initial_status, on: :create

  belongs_to :patient
  belongs_to :submitted_by, class_name: "User"
  belongs_to :completed_by, class_name: "User"

  validates :title, :patient, :submitted_by, :image, presence: true
  validates :status, presence: true, on: :update
  validates_integrity_of :image
  validates_processing_of :image

  private

  def set_form_initial_status
    self.status = :submitted
  end
end
