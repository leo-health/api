require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let!(:guardian_role){create(:role, :guardian)}
  let(:user){ create(:user, :father) }
  let!(:session){ user.sessions.create }


  describe "Get /api/v1/users/:user_id/conversations" do
    def do_request
      get "/api/v1/users/#{user.id}/conversations", {authentication_token: session.authentication_token}
    end

    it 'should only return conversations belong to the user' do
      do_request
      expect(response.status).to eq(200)
      expect_json(user.family.conversation)
    end
  end
end
