require 'airborne'
require 'rails_helper'

describe Leo::V1::Messages do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){create(:user, :guardian)}
  let!(:session){ user.sessions.create }
  let!(:conversation){ user.family.conversation }
  let(:serializer){ Leo::Entities::MessageEntity }

  describe "Get /api/v1/conversations/:conversation_id/messages/full" do
    let(:welcome_message){ conversation.messages.first }
    let!(:first_message){conversation.messages.create(body: "message1", type_name: "text", sender: user)}
    let!(:second_message){conversation.messages.create(body: "message2", type_name: "text", sender: user)}
    let(:serializer){ Leo::Entities::FullMessageEntity }
    let(:customer_service){create(:user, :customer_service)}
    let(:clinical){create(:user, :clinical)}

    before do
      escalate_params = {escalated_to: clinical, note: "note", priority: 1, escalated_by: customer_service}
      conversation.escalate!(escalate_params)
    end

    def do_request
      get "/api/v1/conversations/#{conversation.id}/messages/full", { authentication_token: session.authentication_token }
    end

    it "should return message with system messages(close/escaltion actions)" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect( body[:data][:messages].as_json.to_json).to eq( serializer.represent([EscalationNote.first, second_message, first_message, welcome_message]).as_json.to_json )
    end
  end

  describe "Get /api/v1/conversations/:conversation_id/messages" do
    let!(:first_message){create(:message, conversation: conversation, sender: user, created_at: Time.now + 1.minites)}
    let!(:second_message){create(:message, conversation: conversation, sender: user, created_at: Time.now + 2.minutes)}

    def do_request
      get "/api/v1/conversations/#{conversation.id}/messages?per_page=2&page=1", { authentication_token: session.authentication_token }
    end

    it "should get all the messages of a conversation" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent([second_message, first_message]).as_json.to_json)
    end
  end

  describe "Get /api/v1/messages/:id" do
    let(:message){ conversation.messages.last }

    def do_request
      get "/api/v1/messages/#{message.id}", { authentication_token: session.authentication_token }
    end

    it 'should return a single message' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent(message).as_json.to_json)
    end
  end

  describe "Post /api/v1/conversations/:conversation_id/messages" do
    def do_request
      post "/api/v1/conversations/#{conversation.id}/messages", { body: "test", type_name: "text", authentication_token: session.authentication_token }
    end

    it "should create a message for the conversation" do
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data].as_json.to_json).to eq(serializer.represent(Message.last).as_json.to_json)
    end
  end
end
