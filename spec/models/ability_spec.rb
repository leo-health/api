require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when user has the role super user" do
      let!(:super_user){create(:role, :super_user)}
      let!(:user){create(:user, role: super_user)}

      it{ should be_able_to(:manage, User.new) }
    end

    context "when user has the role guardian" do
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
