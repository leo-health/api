require 'airborne'
require 'rails_helper'

describe Leo::V1::UserConversations do
  describe "Put /api/v1/user_conversations/set_priority" do
    let(:user){create(:user, :guardian)}
    let(:provider){create(:user, :clinical)}

    before do
      user.family.conversation.staff << provider
    end

    def do_request

    end
  end
end
