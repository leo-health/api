require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when is an super user" do
      let!(:user){create(:user)}

      before do
        user.add_role :super_user
      end

      it{ should be_able_to(:manage, User.new) }
    end

    context "when is a guardian" do
     let(:patient){create(:user, :child)}
     let!(:family){patient.family}
     let!(:user){create(:user, :father, family: family)}

     it{should be_able_to(:crud, patient)}
     end
  end
end
