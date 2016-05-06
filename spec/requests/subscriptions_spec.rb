require 'rails_helper'
require 'stripe_mock'

describe Leo::V1::Subscriptions do
  describe "Post /api/v1/subscriptions" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:credit_card_token){ stripe_helper.generate_card_token }
    let(:user){ create(:user) }
    let(:session){ user.sessions.create }
    let(:serializer){ Leo::Entities::UserEntity }

    before do
      Stripe.api_key="test_key"
      StripeMock.start
      stripe_helper.create_plan(id: "com.leohealth.standard-1_child")
      create(:patient, family: user.family)
    end

    after do
      StripeMock.stop
    end

    def do_request
      post "/api/v1/subscriptions", { authentication_token: session.authentication_token,
                                      credit_card_token: credit_card_token
                                     }
    end

    it "subscribe user to stripe subscription" do
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:user].as_json.to_json).to eq(serializer.represent(user.reload).as_json.to_json)
    end
  end
end
