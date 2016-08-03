require 'rails_helper'

RSpec.describe StaffProfile, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:staff).class_name('User') }
    it{ is_expected.to belong_to(:provider) }
    it{ is_expected.to belong_to(:avatar) }
  end

  describe "callbacks" do
    let(:staff_profile){ create(:staff_profile) }
    let(:practice){ create(:practice) }
    let(:staff){ staff_profile.staff }

    context "after_update" do
      describe 'check_on_call_status' do
        before do
          staff.update_attributes(practice: practice)
        end

        it "should broadcast practice availability change based on staff on_call status change" do
          expect(staff.practice).to receive(:broadcast_practice_availability)
          staff_profile.update_attributes(on_call: true)
        end
      end
    end
  end
end
