require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }
    let!(:user){create(:user)}

    context "when user has the role super user" do
      let!(:role){create(:role, :super_user)}

      before do
        user.add_role :super_user
      end

      it{ should be_able_to(:manage, User.new) }
    end

    context "when user has the role guardian" do
      let!(:guardian_role){create(:role, :guardian)}

      before do
        user.add_role :guardian
      end

      describe "ability for User" do

      end

      describe "ability for Conversation" do
        let!(:conversation){create(:conversation, family: user.family)}
        let!(:other_conversation){create(:conversation)}



        it{should_not be_able_to(:read, other_conversation)}
      end
    end

    context "when user has the role financial" do
      let!(:role){create(:role, :financial)}

      before do
        user.add_role :financial
      end

      describe "ability for User" do
        it{should be_able_to(:read, User)}
      end
    end

    context "when user has the role clinical" do
      let!(:role){create(:role, :clinical)}

      before do
        user.add_role :clinical
      end

      describe "ability for User" do
        it{should be_able_to(:read, User)}
      end
    end

    context "when user has the role clinical_support" do
      let!(:role){create(:role, :clinical_support)}

      before do
        user.add_role :clinical_support
      end

      describe "ability for User" do

      end
    end

    context "when user has the role customer_service" do
      let!(:role){create(:role, :customer_service)}

      before do
        user.add_role :customer_service
      end

      describe "ability for User" do

      end
    end
  end
end
