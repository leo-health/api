require 'rails_helper'

RSpec.describe Avatar, type: :model do
  it { should validate_presence_of(:owner) }

  it { should belong_to(:owner) }
end
