require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when is an super user" do
      let!(:user){create(:user)}
      let!(:role){create(:role, :super_user)}

      before do
        user.add_role :super_user
      end

      it{ should be_able_to(:manage, User.new) }
    end

    context "when is a guardian" do
     let!(:patient_role){create(:role, :patient)}
     let!(:guardian_role){create(:role, :guardian)}
     let(:patient){create(:patient)}
     let!(:family){patient.family}
     let!(:user){create(:user, :father, family: family)}

     it{should be_able_to(:read, patient)}
     it{should be_able_to(:destroy, patient)}
     it{should be_able_to(:update, patient)}
     end
  end
end
