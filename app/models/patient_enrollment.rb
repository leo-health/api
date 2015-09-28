class PatientEnrollment < ActiveRecord::Base
  belongs_to :enrollment

  validates :enrollment, presence: true
end
