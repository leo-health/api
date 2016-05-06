require 'rails_helper'
require 'stripe_mock'
require 'rspec_api_documentation/dsl'

resource "Subscriptions" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  before do
    Stripe.api_key="test_key"
    StripeMock.start
    stripe_helper.create_plan(id: "com.leohealth.standard-1_child")
    create(:patient, family: user.family)
  end

  after do
    StripeMock.stop
  end

  post "/api/v1/subscriptions" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :credit_card_token, "Credit Card Token", required: true

    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:credit_card_token){ stripe_helper.generate_card_token }
    let(:user){ create(:user) }
    let(:session){ user.sessions.create }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "create a stripe subscription for user" do
      do_request
      expect(response_status).to eq(201)
    end
  end
end
