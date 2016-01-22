require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'relations' do
    it{ is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    context "if on web platform" do
      before { allow(subject).to receive(:mobile?).and_return(true) }

      it { is_expected.to validate_presence_of(:device_height) }
      it { is_expected.to validate_presence_of(:device_width) }
      it { is_expected.to validate_presence_of(:device_token) }
      it { is_expected.to validate_presence_of(:device_identifier) }
    end
  end
end
