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
        end
      end

      describe "when retrive other user conversation" do
        let!(:other_user){ create(:user) }

        def do_request
          get "/api/v1/users/#{other_user.id}/conversations", {authentication_token: session.authentication_token}
        end

        it "should not return conversations belongs to other user" do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
