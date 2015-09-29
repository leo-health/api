require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user) }
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:session){ user.sessions.create }

  describe "Get /api/v1/users/:user_id/conversations" do
    context "user is a guardian" do
      def do_request
        get "/api/v1/users/#{user.id}/conversations", {authentication_token: session.authentication_token}
      end

      describe "when retrive own converstion" do
        it 'should return conversations belong to the user' do
          do_request
          expect(response.status).to eq(200)
          expect_json("data.conversation.family.id", user.family_id)
        end
      end

      describe "when retrive other user conversation" do
        let!(:guardian_role){create(:role, :guardian)}
        let!(:other_user){ create(:user, :guardian) }

        def do_request
          get "/api/v1/users/#{other_user.id}/conversations", {authentication_token: session.authentication_token}
        end

        it "should not return conversations belongs to other user" do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end

    context "user is a staff" do
      let(:clinical_user){ create(:user, :clinical) }
      let!(:session){ clinical_user.sessions.create }
      let!(:other_user){ create(:user) }

      def do_request
        get "/api/v1/users/#{clinical_user.id}/conversations", {authentication_token: session.authentication_token, state: "new"}
      end

      before do
        conversation_one = Conversation.find_by_family_id(user.family_id)
        conversation_one.staff << clinical_user
        conversation_one.messages.first.read_receipts.create(reader: user)
        conversation_two = Conversation.find_by_family_id(other_user.family_id)
        conversation_two.staff << clinical_user
      end

      describe "fetch all conversations of the user" do
        it "should show all conversations of user" do
          do_request
          expect(response.status).to eq(200)
          expect_json_sizes("data.conversations", 2)
        end
      end
    end
  end

  describe "Put /api/v1/conversations/:id/close" do
    let(:clinial_user){create(:user, :clinical)}
    let!(:session){ clinial_user.sessions.create }
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }

    before do
      conversation.update_attributes(status: :open)
    end

    def do_request
      put "/api/v1/conversations/#{conversation.id}/close", {authentication_token: session.authentication_token}
    end

    it "should update the specific conversation" do
      expect(conversation.status).to eq("open")
      do_request
      expect(response.status).to eq(200)
      expect_json("data.conversation.status", "closed")
    end
  end

  describe "Put /api/v1/conversations/:id/escalate" do

  end

  describe "Get /api/v1/conversations" do
    let(:clinial_user){create(:user, :clinical)}
    let!(:session){ clinial_user.sessions.create }
    let!(:family ){ create(:family)}
    let!(:family_one ){ create(:family)}
    let!(:family_two ){ create(:family)}
    let!(:formatter){ Leo::Entities::ConversationEntity }

    before do
      @conversation = family.conversation
      @conversation.update_attributes(status: :open)
      @escalated_conversation = family_one.conversation
      @escalated_conversation.update_attributes(status: :escalated)
      @closed_conversation = family_two.conversation
      @closed_conversation.update_attributes(status: :closed)
    end

    def do_request
      get "/api/v1/conversations", {authentication_token: session.authentication_token}
    end

    it "should return all the conversations" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:conversations].as_json.to_json).to eq( formatter.represent([@conversation, @escalated_conversation, @closed_conversation ] ).as_json.to_json)
    end
  end
end
