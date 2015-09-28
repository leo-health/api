require 'rails_helper'

RSpec.describe PatientEnrollment, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:guardian_enrollment).class_name('Enrollment') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:guardian_enrollment) }
  end
end
