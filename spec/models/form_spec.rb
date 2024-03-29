require 'rails_helper'

RSpec.describe Form, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to belong_to(:submitted_by) }
    it { is_expected.to belong_to(:completed_by) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:status).on(:update) }
    it { is_expected.to validate_presence_of(:image) }
    it { is_expected.to validate_presence_of(:patient) }
    it { is_expected.to validate_presence_of(:submitted_by) }
  end

  describe 'callbacks' do
    it { is_expected.to callback(:set_form_initial_status).before(:validation).on(:create) }
  end
end
