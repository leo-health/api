require 'rails_helper'

RSpec.describe Choice, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:question) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:choice_type) }
    it { is_expected.to validate_inclusion_of(:choice_type).in_array(%w(structured unstructured)) }
  end
end
