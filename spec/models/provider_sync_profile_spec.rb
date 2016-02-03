require 'rails_helper'

RSpec.describe ProviderSyncProfile, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:provider).class_name('User') }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:provider) }
  end
end
