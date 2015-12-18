require 'rails_helper'

RSpec.describe MessagePhoto, type: :model do
  it { should validate_presence_of(:message) }

  it { should belong_to(:message) }
end
