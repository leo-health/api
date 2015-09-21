require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe "ActiveModel validations" do
    let(:enrollment){create(:enrollment)}
    it { expect(:enrollment).to validate_presence_of(:email)}
  end
end
