require 'rails_helper'

RSpec.describe EscalationNote, type: :model do
  it{ is_expected.to belong_to(:message) }
  it{ is_expected.to belong_to(:assignor).class_name('User') }
  it{ is_expected.to belong_to(:assignee).class_name('User') }

  it { is_expected.to validate_presence_of(:assignor) }
  it { is_expected.to validate_presence_of(:message) }
  it { is_expected.to validate_presence_of(:assignee) }
  it { is_expected.to validate_presence_of(:priority_level) }
end
