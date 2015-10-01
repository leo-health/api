require 'rails_helper'

RSpec.describe PatientEnrollment, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:guardian_enrollment).class_name('Enrollment') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:guardian_enrollment) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:birth_date) }
    it { is_expected.to validate_presence_of(:sex) }
  end
end
