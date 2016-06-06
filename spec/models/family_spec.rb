require 'rails_helper'

describe Family, type: :model do
  before do
    Stripe.api_key="test_key"
    StripeMock.start
    StripeMock.create_test_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)
  end

  let!(:user){ create(:user, :member) }
  let!(:patient){ create(:patient, family: user.family) }
  let!(:second_patient){ create(:patient, family: user.family) }

  describe ".stripe_customer=" do
    it "has a stripe customer with limited fields" do
      user.family.update_or_create_stripe_subscription_if_needed!
      expect(user.family.stripe_customer).to eq(
        {
          "id"=>"test_cus_3",
          "subscriptions"=>{
            "data"=>[
              {
                "id"=>"test_su_4",
                "quantity"=>2,
                "plan"=>{
                  "id"=>"com.leohealth.standard",
                  "amount"=>2000
                }
              }
            ]
          }
        }
      )
    end
  end
end
