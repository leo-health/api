require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe "ActiveModel validations" do
    it { should validate_presence_of(:email)}
    it { should validate_length_of(:password).is_at_least(8)}
  end
end
