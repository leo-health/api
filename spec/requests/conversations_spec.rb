require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:bot){ create(:user, :bot) }
  let(:serializer){ Leo::Entities::ConversationEntity }
  let(:short_serializer){ Leo::Entities::ShortConversationEntity }
  let(:reason_serializer) { Leo::Entities::ClosureReasonEntity }

  describe "Get /api/v1/staff/:staff_id/conversations" do
    let(:session){ customer_service.sessions.create }

    before do
      @conversation_one = Conversation.find_by_family_id(user.family_id)
      @conversation_one.messages.create(body: 'test', sender: customer_service, type_name: 'text')
    end

    context "all particpated conversations" do
      def do_request
        get "/api/v1/staff/#{customer_service.id}/conversations", {authentication_token: session.authentication_token}
      end

      it "should return all conversations the staff participated" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect( body[:data][:conversations].as_json.to_json).to eq(short_serializer.represent([@conversation_one]).as_json.to_json)
      end
    end

    context "assigned conversations" do
      before do
        @conversation_one.escalate!(note: 'test', escalated_by: customer_service, priority: 1, escalated_to: customer_service)
      end

      def do_request
        get "/api/v1/staff/#{customer_service.id}/conversations", {state: :escalated,
                                                                   authentication_token: session.authentication_token}
      end

      it "should return all conversations the staff participated" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect( body[:data][:conversations].as_json.to_json).to eq(short_serializer.represent([@conversation_one]).as_json.to_json)
      end
    end
  end

  describe "Get /api/v1/conversations/closure_reasons" do
    let(:clinical_user){ create(:user, :clinical) }
    let(:session){ clinical_user.sessions.create }
    let!(:reason){ create(:closure_reason) }

    def do_request
      get "/api/v1/conversations/closure_reasons", { authentication_token: session.authentication_token }
    end

    it "should return the closure reasons" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:reasons].as_json.to_json).to eq(reason_serializer.represent([reason]).as_json.to_json)
    end
  end

  describe "Put /api/v1/conversations/:id/close" do
    let(:clinical_user){create(:user, :clinical)}
    let!(:session){ clinical_user.sessions.create }
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }

    before do
      conversation.update_attributes(state: :open)
    end

    def do_request
      put "/api/v1/conversations/#{conversation.id}/close", {authentication_token: session.authentication_token, userInput: true, note: "close conversation", reasonId: 1}
    end

    it "should update the specific conversation" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect( body[:data][:message_type].to_sym).to eq(:close)
    end
  end

  describe "Put /api/v1/conversations/:id/escalate" do
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }
    let(:clinical_user){ create(:user, :clinical) }
    let(:session){ customer_service.sessions.create }

    before do
      conversation.update_attributes(state: :open)
    end

    def do_request
      escalation_params = { note: "note", priority: 1, escalated_to_id: clinical_user.id, authentication_token: session.authentication_token }
      put "/api/v1/conversations/#{conversation.id}/escalate", escalation_params
    end

    it "should update the specific conversation" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect( body[:data][:message_type].to_sym).to eq(:escalation)
    end
  end

  describe "Get /api/v1/conversations" do
    let(:clinical_user){create(:user, :clinical) }
    let!(:session){ clinical_user.sessions.create }
    let!(:family ){ create(:family_with_members) }
    let!(:family_one ){ create(:family_with_members) }
    let!(:family_two ){ create(:family_with_members) }

    before do
      @new_conversation = family.conversation
      @conversation = family_one.conversation
      @old_conversation = family_two.conversation
      @conversation.update_attributes(updated_at: Time.now - 1.day)
      @new_conversation.update_attributes(updated_at: Time.now)
      @old_conversation.update_attributes(updated_at: Time.now - 2.day)
    end

    def do_request
      get "/api/v1/conversations", {authentication_token: session.authentication_token}
    end

    it "should return all the conversations" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:conversations].as_json.to_json).to include(*short_serializer.represent([@new_conversation, @conversation, @old_conversation]).as_json.to_json)
    end
  end

  describe "Get /api/v1/families/:family_id/conversation" do
    def do_request
      get "/api/v1/families/#{user.family_id}/conversation", {authentication_token: session.authentication_token}
    end

    it "should return the conversation of the requested family" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:conversation].as_json.to_json).to eq( short_serializer.represent(user.family.conversation).as_json.to_json)
    end
  end

  describe "Get /api/v1/conversations/:id" do
    let(:conversation){ user.family.conversation }

    def do_request
      get "/api/v1/conversations/#{conversation.id}", {authentication_token: session.authentication_token}
    end

    it "should return the conversation requested by id" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:conversation].as_json.to_json).to eq( short_serializer.represent(conversation).as_json.to_json)
    end
  end
end
