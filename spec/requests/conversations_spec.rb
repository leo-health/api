require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let!(:guardian_role){create(:role, :guardian)}
  let(:user){ create(:user, :father) }
  let!(:conversation){create(:conversation, family: user.family)}
  let!(:session){ user.sessions.create }


  describe "Get /api/v1/users/:user_id/conversations" do
    let!(:other_conversation){create(:conversation, family: user.family)}

    def do_request
      byebug
      get "/api/v1/users/#{user.id}/conversations", {authentication_token: session.authentication_token}
    end

    it 'should return conversations belong to the user' do
      do_request
      byebug
      expect(response.status).to eq(200)
      expect_json(user.conversations)
    end
  end

  describe "Get /api/v1/users/:user_id/conversations/:id" do
    def do_request
      get "/api/v1/users/#{user.id}/conversations/#{conversation.id}", {authentication_token: session.authentication_token}
    end

    it 'should return one specific conversation' do
      do_request
      expect(response.status).to eq(200)
      expect_json(user.conversations.find(conversation.id))
    end
  end
end
