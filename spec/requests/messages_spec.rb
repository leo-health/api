require 'airborne'
require 'rails_helper'

describe Leo::V1::Messages do
  let(:user){create(:user)}
  let!(:session){ user.sessions.create }
  let!(:conversation){ user.family.conversation }
  let!(:guardian_role){create(:role, :guardian)}

  before do
    user.add_role :guardian
  end

  describe "Get /api/v1/conversations/:conversation_id/messages" do
    let!(:first_message){create(:message, conversation: conversation, sender: user)}
    let!(:second_message){create(:message, conversation: conversation, sender: user)}

    def do_request
      get "/api/v1/conversations/#{conversation.id}/messages?per_page=2&page=1", { authentication_token: session.authentication_token }
    end

    it "should get all the messages of a conversation" do
      do_request
      expect(response.status).to eq(200)
      expect_json_sizes("data", 2)
    end
  end

  describe "Post /api/v1/conversations/:conversation_id/messages" do
    def do_request
      post "/api/v1/conversations/#{conversation.id}/messages",
           { body: "test", type_name: "text", authentication_token: session.authentication_token }
    end

    it "should create a message for the conversation" do
      do_request
      expect(response.status).to eq(201)
    end
  end
end
