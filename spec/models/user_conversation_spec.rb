require 'rails_helper'

RSpec.describe UserConversation, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:staff).class_name('User').with_foreign_key('user_id') }
    it{ is_expected.to belong_to(:conversation).with_foreign_key('conversation_id') }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.to validate_presence_of(:conversation) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:conversation_id) }
  end
end
