class PatientEnrollment < ActiveRecord::Base
  belongs_to :guardian_enrollment, class_name: 'Enrollment'

  validates :guardian_enrollment, presence: true
end
