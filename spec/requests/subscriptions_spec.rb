require 'rails_helper'
require 'stripe_mock'

describe Leo::V1::Subscriptions do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:credit_card_token){ stripe_helper.generate_card_token }
  let(:user){create(:user, email: "bigtree@gmail.com", password: "password")}
  let(:session){ user.sessions.create }

  before do
    Stripe.api_key="test_key"
    StripeMock.start
    stripe_helper.create_plan(id: "com.leohealth.standard-1_child")
    create(:patient, family: user.family)
  end

  after do
    StripeMock.stop
  end

  describe "Post /api/v1/subscriptions" do
    def do_request
      post "/api/v1/subscriptions", {
        authentication_token: session.authentication_token,
        credit_card_token: credit_card_token
      }
    end

    it "subscribes a user to stripe subscription" do
      previous_membership_type = user.family.membership_type
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data]).to be(true)
      expect(user.family.membership_type).to be(previous_membership_type)
      expect(user.family.stripe_customer).to eq({})
    end

    it "fails to charge card" do
      allow(Stripe::Customer).to receive(:create).and_raise(StripeMock.prepare_card_error(:card_declined).first.first.second)
      do_request
      expect(response.status).to eq(422)
      expect(user.family.reload.membership_type).to eq("delinquent")
    end
  end

  describe "Put /api/v1/subscriptions" do
    before do
      user.family.expire_membership
      user.family.update stripe_customer_id: "fake_customer_id"
    end

    def do_request
      put "/api/v1/subscriptions", {
        authentication_token: session.authentication_token,
        credit_card_token: credit_card_token
      }
    end

    it "updates a users stripe card" do
      previous_membership_type = user.family.membership_type
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data]).to be(true)
      expect(user.family.membership_type).to be(previous_membership_type)
      expect(user.family.stripe_customer).to eq({})
    end

    it "fails to charge card" do
      allow(Stripe::Customer).to receive(:create).and_raise(StripeMock.prepare_card_error(:card_declined).first.first.second)
      do_request
      expect(response.status).to eq(422)
      expect(user.family.reload.membership_type).to eq("delinquent")
    end
  end
end
