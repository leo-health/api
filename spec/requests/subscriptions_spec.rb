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
    stripe_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)
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
      expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(0)
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data]).to eq({
        id: "test_cus_3",
        subscriptions: {
          data: [
            {
              id: "test_su_4",
              quantity: 1,
              plan: {
                id: "com.leohealth.halfprice",
                amount: 1000
              }
            }
          ]
        }
      })
      fam = user.family.reload
      expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(1)
      expect(Delayed::Job.where(queue: PaymentsMailer.queue_name, owner: user).count).to be(1)
      expect(fam.membership_type).to eq("member")
      expect(fam.stripe_customer).not_to eq({})
      expect(fam.stripe_subscription_id).not_to be_nil
    end

    it "fails to charge card" do
      allow(Stripe::Customer).to receive(:create).and_raise(StripeMock.prepare_card_error(:card_declined).first.first.second)
      do_request
      expect(response.status).to eq(422)
      expect(Delayed::Job.where(queue: PaymentsMailer.queue_name, owner: user).count).to be(0)
      expect(user.family.reload.membership_type).to eq("delinquent")
    end
  end

  describe "Put /api/v1/subscriptions" do
    let(:second_credit_card_token){ stripe_helper.generate_card_token }

    def do_request
      put "/api/v1/subscriptions", {
        authentication_token: session.authentication_token,
        credit_card_token: second_credit_card_token
      }
    end

    context "when delinquent" do
      before do
        user.family.update_or_create_stripe_subscription_if_needed! credit_card_token
        user.family.expire_membership!
      end

      it "updates a users stripe card" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data]).to eq({
          id: "test_cus_3",
          subscriptions: {
            data: [
              {
                id: "test_su_4",
                quantity: 1,
                plan: {
                  id: "com.leohealth.halfprice",
                  amount: 1000
                }
              }
            ]
          }
        })
        fam = user.family.reload
        expect(fam.membership_type).to eq("member")
        expect(fam.stripe_customer).not_to eq({})
        expect(fam.stripe_subscription_id).not_to be_nil
      end

      it "fails to charge card" do
        allow_any_instance_of(Stripe::Customer).to receive(:save).and_raise(StripeMock.prepare_card_error(:card_declined).first.first.second)
        do_request
        expect(response.status).to eq(422)
        expect(user.family.reload.membership_type).to eq("delinquent")
      end
    end

    context "when exempted" do
      before do
        user.family.exempt_membership!
      end

      it "creates a customer with no plan" do
        do_request
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data]).to eq({ id: "test_cus_3", })
        fam = user.family.reload
        expect(fam.membership_type).to eq("exempted")
        expect(Delayed::Job.where(queue: PaymentsMailer.queue_name, owner: user).count).to be(0)
        expect(fam.stripe_customer).not_to eq({})
        expect(fam.stripe_subscription_id).to be_nil
      end
    end
  end

  describe "Get /api/v1/subscriptions/validate_coupon" do
    let!(:coupon){ Stripe::Coupon.create(:percent_off => 25, :duration => 'once', :id => 'NEWPARENT16')}

    def do_request
      get "/api/v1/subscriptions/validate_coupon", { authentication_token: session.authentication_token,
                                                     coupon_id: 'NEWPARENT16' }
    end

    it "should return the coupon if the coupon code is valid" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['data']['coupon']).to eq(coupon.as_json)
      expect(body['data']['text']).to eq('Your first month of membership is on us!')
    end
  end
end
