require 'rails_helper'

RSpec.describe EscalationNote, type: :model do
  it{ is_expected.to belong_to(:conversation) }
  it{ is_expected.to belong_to(:escalated_by).class_name('User') }
  it{ is_expected.to belong_to(:escalated_to).class_name('User') }

  it { is_expected.to validate_presence_of(:escalated_by) }
  it { is_expected.to validate_presence_of(:conversation) }
  it { is_expected.to validate_presence_of(:escalated_to) }
  it { is_expected.to validate_presence_of(:priority) }
end
