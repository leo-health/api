require "rails_helper"
describe SyncService do
  before do
    Stripe.api_key="test_key"
    StripeMock.start
    StripeMock.create_test_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)

    Delayed::Job.destroy_all

    provider = create(:provider)
    incomplete_family = create(:family)
    member_family = create(:user, :member, practice: provider.practice).family
    5.times { create(:patient, family: incomplete_family) }
    10.times { create(:patient, family: member_family) }
  end

  describe ".start" do
    it "adds delayed jobs to the queue only for members" do
      SyncService.start
      expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(10)
      expect(Delayed::Job.where(queue: SyncPracticeJob.queue_name).count).to be(1)
      expect(Delayed::Job.where(queue: SyncProviderJob.queue_name).count).to be(1)
    end
  end
end
