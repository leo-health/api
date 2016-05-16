require 'rails_helper'

RSpec.describe StaffProfile, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:staff).class_name('User') }
  end

  describe "validations" do

  end
end
