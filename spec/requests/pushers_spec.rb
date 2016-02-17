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

  describe "POST /api/v1/pusher/webhooks" do
    def signature_for(body)
      digest = OpenSSL::Digest::SHA256.new
      secret = PusherFake.configuration.secret
      OpenSSL::HMAC.hexdigest(digest, secret, body)
    end

    def do_request
      body = { events: [{ "name": "member_added", channel: "presence-test", user_id: "1" }] }
      payload = MultiJson.dump(body)
      header = {
                 "Content-Type": "application/json",
                 "X-Pusher-Key": PusherFake.configuration.key,
                 "X-Pusher-Signature": signature_for(payload)
                }

      post "/api/v1/pusher/webhooks", payload, header
    end

    it "should receive webhook to set user online status" do
      do_request
      expect(response.status).to eq(201)
      expect($redis.get("#{1}online?")).to eq("yes")
    end
  end
end
