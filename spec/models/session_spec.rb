require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'relations' do
    it{ is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    context "if on web platform" do
      before { allow(subject).to receive(:mobile?).and_return(true) }

      it { is_expected.to validate_presence_of(:device_type) }
      it { is_expected.to validate_presence_of(:device_token) }
    end
  end
end
