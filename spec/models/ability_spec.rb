require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when user has the role super user" do
      let!(:user){create(:user, :super_user)}

      it{ should be_able_to(:manage, User.new) }
    end

    context "when user has the role guardian" do
     let!(:patient){create(:patient)}
     let!(:family){patient.family}
     let!(:user){create(:user, :father, family: family)}

     it{should be_able_to(:read, patient)}
     it{should be_able_to(:destroy, patient)}
     it{should be_able_to(:update, patient)}
     end
  end
end
