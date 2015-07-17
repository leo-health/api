require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when is an account manager" do
      let!(:user){create(:user)}

      before do
        user.add_role :super_user
      end

      it{ should be_able_to(:manage, User.new) }
    end
  end
end
