require 'rails_helper'

RSpec.describe CloseConversationNote, type: :model do
  it{ is_expected.to belong_to(:conversation) }
  it{ is_expected.to belong_to(:closed_by).class_name('User') }

  it { is_expected.to validate_presence_of(:closed_by) }
  it { is_expected.to validate_presence_of(:conversation) }
end
