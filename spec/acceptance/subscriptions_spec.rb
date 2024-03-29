require 'rails_helper'
require 'stripe_mock'
require 'rspec_api_documentation/dsl'

resource "Subscriptions" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let!(:user){ create(:user) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  before do
    Stripe.api_key="test_key"
    StripeMock.start
    stripe_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)
  end

  after do
    StripeMock.stop
  end

  post "/api/v1/subscriptions" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :credit_card_token, "Credit Card Token", required: true
    parameter :coupon_id, "Promo Code"

    let(:credit_card_token){ stripe_helper.generate_card_token }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "create a stripe subscription for enrollment" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  get "/api/v1/subscriptions/validate_coupon" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :coupon_id, "Promo Code", required: true

    let(:authentication_token){ session.authentication_token }
    let(:coupon_id){ 'NEWPARENT16'}
    let(:raw_post){ params.to_json }

    before do
      Stripe::Coupon.create(:percent_off => 100, :duration => 'once', :id => 'NEWPARENT16')
    end

    example "validate a stripe promo code" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
