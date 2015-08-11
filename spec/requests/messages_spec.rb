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

  describe "Get /api/v1/conversations/:conversatoin_id/messages" do
    let!(:first_message){create(:message, conversation: conversation, sender: user)}
    let!(:second_message){create(:message, conversation: conversation, sender: user)}

    def do_request
      get "/api/v1/conversations/#{conversation.id}/messages", { authentication_token: session.authentication_token }
    end

    it "should get all the messages of a conversation" do
      do_request
      expect(response.status).to eq(200)
      expect_json_sizes("data.messages", 2)
    end
  end

  describe "Post /api/v1/conversations/:conversatoin_id/messages" do
    let!(:message_params){{body: "test", message_type: "text"}}

    def do_request
      post "/api/v1/conversations/#{conversation.id}/messages", { body: "test", message_type: "text", authentication_token: session.authentication_token }
    end

    it "should create a message for the conversation" do
      do_request
      expect(response.status).to eq(201)
    end
  end

  #routes? need discuss here
  describe "Get /api/v1/conversations/:conversatoin_id/messages/:message_id" do
    let!(:first_message){create(:message, conversation: conversation, sender: user)}

    def do_request
      get "/api/v1/conversations/#{conversation.id}/messages/#{message.id}", { authentication_token: session.authentication_token }
    end

    it "should return the request message of the conversation" do

    end
  end

  describe "Put /api/v1/conversations/:conversatoin_id/messages/:message_id" do
    def do_request
      put "/api/v1/conversations/#{conversation.id}/messages/#{message.id}", { authentication_token: session.authentication_token }

      it "should update the requested message" do

      end
    end
  end
end
