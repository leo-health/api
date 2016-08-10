require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:bot){ create(:user, :bot) }
  let(:serializer){ Leo::Entities::ConversationEntity }
  let(:short_serializer){ Leo::Entities::ShortConversationEntity }

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

    context "for guardian user" do
      let(:guardian_session){ user.sessions.create }

      def do_request
        get "/api/v1/staff/#{customer_service.id}/conversations", {authentication_token: guardian_session.authentication_token}
      end

      it "should not allow guardian to fetch the conversation" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Put /api/v1/conversations/:id/close" do
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }

    before do
      conversation.update_attributes(state: :open)
    end

    context "for staff" do
      let(:clinical_user){create(:user, :clinical)}
      let!(:session){ clinical_user.sessions.create }

      def do_request
        put "/api/v1/conversations/#{conversation.id}/close", {authentication_token: session.authentication_token, note: "close conversation"}
      end

      it "should close the specific conversation" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect( body[:data][:message_type].to_sym).to eq(:close)
      end
    end

    context "for guardian" do
      def do_request
        put "/api/v1/conversations/#{conversation.id}/close", {authentication_token: session.authentication_token, note: "close conversation"}
      end

      it "should not allow guardian to close conversation" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Put /api/v1/conversations/:id/escalate" do
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }
    let(:clinical_user){ create(:user, :clinical) }

    def do_request
      escalation_params = { note: "note", priority: 1, escalated_to_id: clinical_user.id, authentication_token: session.authentication_token }
      put "/api/v1/conversations/#{conversation.id}/escalate", escalation_params
    end

    context 'for staff' do
      let(:session){ customer_service.sessions.create }

      before do
        conversation.update_attributes(state: :open)
      end

      it "should update the specific conversation" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect( body[:data][:message_type].to_sym).to eq(:escalation)
      end
    end

    context 'for guardian' do
      let(:session){ user.sessions.create }

      before do
        conversation.update_attributes(state: :open)
      end

      it "should not allow guardian to escalate the conversation" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Get /api/v1/conversations" do
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

    context "for user belongs to conversation" do
      let(:clinical_user){create(:user, :clinical) }
      let!(:session){ clinical_user.sessions.create }

      it "should return all the conversations" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:conversations].as_json.to_json).to include(*short_serializer.represent([@new_conversation, @conversation, @old_conversation ] ).as_json.to_json)
      end
    end

    context "for user not belongs to conversation" do
      it "should not return any conversation" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Get /api/v1/conversations/:id" do
    let(:conversation){ user.family.conversation }

    def do_request
      get "/api/v1/conversations/#{conversation.id}", {authentication_token: session.authentication_token}
    end

    context 'when guardian belongs to conversation' do
      it "should return the conversation requested by id" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:conversation].as_json.to_json).to eq( short_serializer.represent(conversation).as_json.to_json)
      end
    end

    context 'when staff' do
      let!(:session){ customer_service.sessions.create }

      it "should return the conversation requested by id" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:conversation].as_json.to_json).to eq( short_serializer.represent(conversation).as_json.to_json)
      end
    end

    context 'when guardian not belongs to conversation' do
      let(:guardian){ create(:user) }
      let!(:session){ guardian.sessions.create }

      it "should not return the requested conversation" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Get /api/v1/families/:family_id/conversation" do
    def do_request
      get "/api/v1/families/#{user.family_id}/conversation", {authentication_token: session.authentication_token}
    end

    context 'guardian belongs to conversation' do
      it "should return the conversation of the requested family" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:conversation].as_json.to_json).to eq( short_serializer.represent(user.family.conversation).as_json.to_json)
      end
    end

    context 'guardian not belongs to conversation' do
      let(:guardian_of_other_family){create(:user) }
      let!(:session){ guardian_of_other_family.sessions.create }

      it "should return the conversation of the requested family" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end
end
