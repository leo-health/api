require 'rails_helper'

RSpec.describe EscalationNote, type: :model do
  it{ should belong_to(:message) }
  it do
    should belong_to(:assignor).
      conditions.not(role_id: 4)
  end
end
