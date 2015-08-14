require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user) }
  let!(:session){ user.sessions.create }


  describe "Get /api/v1/users/:user_id/conversations" do
    def do_request
      get "/api/v1/users/#{user.id}/conversations", {authentication_token: session.authentication_token}
    end

    context "user is a guardian" do
      let!(:guardian_role){create(:role, :guardian)}

      before do
        user.add_role :guardian
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
      let!(:clinical_role){create(:role, :clinical)}
      let!(:other_user){ create(:user) }

      before do
        user.add_role :clinical
        Conversation.find_by_family_id(user.family_id).staff << user
        Conversation.find_by_family_id(other_user.family_id).staff << user
      end

      it "should show all conversations of user" do
        do_request
        expect(response.status).to eq(200)
        expect_json_sizes("data.conversations", 2)
      end
    end
  end

  describe "Put /api/v1/conversations/:id" do
    let(:clinial_user){create(:user, :clinical)}
    let!(:session){ clinial_user.sessions.create }
    let(:conversation){ Conversation.find_by_family_id(user.family_id) }

    def do_request
      put "/api/v1/users/#{user.id}/conversations/#{conversation.id}", {authentication_token: session.authentication_token}
    end

    it "should update the specific conversation" do

    end
  end

  describe "Get /api/v1/conversations" do

  end
end


# put ":id" do
#   conversation = Conversation.find(params[:id])
#   if conversation.try(:update_attributes, {status: "closed"})
#     present :conversation, conversation, with: Leo::Entities::ConversationEntity
#   end
# end
