require 'rails_helper'

describe Leo::V1::Pushers do
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }


  describe "POST /api/v1/pusher/auth" do
    def do_request
      post "/api/v1/pusher/auth", {  authentication_token: session.authentication_token,
                                     channel_name: "newStatus#{user.email}",
                                     socket_id: '123.456' }
    end

    it "should authenticate requested puhser channel" do
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:auth]).not_to be_empty
      expect(body[:data][:channel_data]).to eq({ user_id: user.id }.as_json.to_json)
    end
  end
end
