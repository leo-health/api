require 'rails_helper'

describe Family, type: :model do
  before do
    Stripe.api_key="test_key"
    StripeMock.start
    StripeMock.create_test_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)
  end

  let!(:bot){ create(:user, :bot) }
  let!(:user){ create(:user, :member) }
  let!(:family){ user.family }
  let!(:patient){ create(:patient, family: family) }
  let!(:second_patient){ create(:patient, family: family) }
  let!(:secondary_guardian){ create(:user, family: family) }

  describe ".complete_all_guardians" do
    context "when secondary_guardian is not confirmed" do
      it "makes all guardians complete except the secondary" do
        expect(User.where(family: family).count).to eq(2)
        expect(family.guardians.count).to eq(1)
        family.complete_all_guardians!
        expect(family.reload.guardians.count).to eq(1)
      end
    end

    context "when secondary guardian is confirmed" do
      before do
        secondary_guardian.confirm
      end

      it "makes all guardians complete" do
        expect(User.where(family: family).count).to eq(2)
        expect(family.guardians.count).to eq(1)
        family.complete_all_guardians!
        expect(family.reload.guardians.size).to eq(2)
      end
    end
  end

  describe ".stripe_customer=" do
    it "has a stripe customer with limited fields" do
      family.update_or_create_stripe_subscription_if_needed!
      expect(family.stripe_customer).to eq(
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

  describe ".destroy" do
    it "destroys patients, guardians, conversation, messages" do
      family.reload
      expect(Family.count).to eq(1)
      expect(family.patients.count).to eq(2)
      expect(Patient.count).to eq(2)
      expect(family.guardians.count).to eq(1)
      expect(User.count).to eq(3)
      expect(Conversation.count).to eq(1)
      expect(Message.count).to eq(1)
      family.destroy!
      expect(Family.count).to eq(0)
      expect(family.patients.count).to eq(0)
      expect(Patient.count).to eq(0)
      expect(family.guardians.count).to eq(0)
      expect(User.count).to eq(2)
      expect(Conversation.count).to eq(0)
      expect(Message.count).to eq(0)
    end
  end
end
