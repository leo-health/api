require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user) }
  let!(:session){ user.sessions.create }

  describe "Get /api/v1/users/:user_id/conversations" do
    def do_request
      get "/api/v1/users/#{user.id}/conversations", {authentication_token: session.authentication_token}
    end

    it 'should return conversations belong to the user' do
      do_request
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
