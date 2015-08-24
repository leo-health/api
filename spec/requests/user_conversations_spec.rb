require 'airborne'
require 'rails_helper'

describe Leo::V1::UserConversations do
  describe "Put /api/v1/user_conversations/set_priority" do
    let!(:user){ create(:user, :guardian) }
    let(:provider){ create(:user, :clinical) }
    let(:session){ provider.sessions.create }

    before do
      user.family.conversation.staff << provider
    end

    def do_request
      user_conversation_params = { user_id: provider.id,
                                   conversation_id: user.family.conversation.id,
                                   priority: 1,
                                   authentication_token: session.authentication_token
                                  }

      put "/api/v1/user_conversations/set_priority", user_conversation_params
    end

    it "should update the priority of the user_conversation" do
      do_request
      expect(response.status).to eq(200)
      expect_json("data.user_conversation.priority", 1)
    end
  end
end
