require 'airborne'
require 'rails_helper'

describe Leo::V1::Messages do
  let(:user){create(:user, :guardian)}
  let!(:session){ user.sessions.create }
  let!(:conversation){ user.family.conversation }
  let(:serializer){ Leo::Entities::MessageEntity }

  before do
    in_hour_time = Time.new(2016, 3, 4, 12, 0, 0, "-05:00")
    Timecop.travel(in_hour_time)
  end

  after do
    Timecop.return
  end

  describe "Get /api/v1/conversations/:conversation_id/messages/full" do
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
      expect( (body[:data][:messages].sort_by {|m| m["id"]}).as_json.to_json).to eq( serializer.represent([EscalationNote.first, second_message, first_message]).as_json.to_json )
    end
  end

  describe "Get /api/v1/conversations/:conversation_id/messages" do

    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    let!(:first_message){create(:message, conversation: conversation, sender: user, created_at: 10.days.ago)}
    let!(:second_message){create(:message, conversation: conversation, sender: user, created_at: 5.days.ago)}
    let!(:third_message){create(:message, conversation: conversation, sender: user, created_at: 0.days.ago)}

    def do_request(params = {})
      get "/api/v1/conversations/#{conversation.id}/messages?per_page=3&page=1", { authentication_token: session.authentication_token }.merge(params)
    end

    context "when requesting all messages" do
      it "should get all the messages of a conversation" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent([third_message, second_message, first_message]).as_json.to_json)
      end
    end

    context "when requesting messages after a certain date" do
      it "should get all the messages after start_datetime" do
        do_request({start_datetime: 5.days.ago.iso8601})
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent([third_message]).as_json.to_json)
      end
    end

    context "when requesting messages before a certain date" do
      it "should get all the messages before end_datetime" do
        do_request({end_datetime: 5.days.ago.iso8601})
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent([first_message]).as_json.to_json)
      end
    end

    context "when requesting messages within a certain date range" do
      it "should get all the messages after start_datetime and before end_datetime" do
        do_request({start_datetime: 10.days.ago.iso8601, end_datetime: 0.days.ago.iso8601})
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent([second_message]).as_json.to_json)
      end
    end
  end

  describe "Get /api/v1/messages/:id" do
    let(:message){ create(:message, conversation: conversation) }

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
    context "when create a text message" do
      def do_request
        post "/api/v1/conversations/#{conversation.id}/messages", { body: "test",
                                                                    type_name: "text",
                                                                    authentication_token: session.authentication_token
                                                                   }
      end

      it "should create a message for the conversation" do
        do_request
        expect(response.status).to eq(201)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent(Message.last).as_json.to_json)
      end
    end

    context "when create a photo message" do
      def do_request
        image = open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}
        encoded_image = Base64.encode64(image)
        post "/api/v1/conversations/#{conversation.id}/messages", { body: encoded_image,
                                                                    type_name: "image",
                                                                    authentication_token: session.authentication_token
                                                                  }

      end

      it "should create a message with message_photo" do
        expect{ do_request }.to change{ MessagePhoto.count }.from(0).to(1)
        expect(response.status).to eq(201)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data].as_json.to_json).to eq(serializer.represent(Message.last).as_json.to_json)
      end
    end
  end
end
