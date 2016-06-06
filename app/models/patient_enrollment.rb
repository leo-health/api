class PatientEnrollment < ActiveRecord::Base
  belongs_to :guardian_enrollment, class_name: 'Enrollment'
  validates :guardian_enrollment, :first_name, :last_name, :birth_date, :sex, presence: true
end
