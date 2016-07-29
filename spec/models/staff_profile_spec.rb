require 'rails_helper'

RSpec.describe StaffProfile, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:staff).class_name('User') }
    it{ is_expected.to belong_to(:provider) }
    it{ is_expected.to belong_to(:avatar) }
  end

  describe "callbacks" do
    describe "after_update"
  end
end
