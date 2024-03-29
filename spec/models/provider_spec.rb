require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user).class_name('User') }
  end

  describe "sync jobs" do
    let!(:provider){ create(:provider) }

    context "on create" do
      it { expect(provider).to callback(:subscribe_to_athena).after(:commit).on(:create) }
    end

    describe "#subscribe_to_athena" do
      before do
        @provider = provider
      end

      context "no SyncProviderJob exists" do
        before { Delayed::Job.destroy_all }
        it "adds a SyncProviderJob to the queue" do
          expect{ @provider.subscribe_to_athena }.to change{
            Delayed::Job.where(queue: SyncProviderJob.queue_name, owner:@provider).count
          }.by(1)
        end
      end

      context "a SyncProviderJob already exists" do
        it "does not add a SyncProviderJob" do
          expect{ @provider.subscribe_to_athena }.to change{
            Delayed::Job.where(queue: SyncProviderJob.queue_name, owner:@provider).count
          }.by(0)
        end
      end
    end
  end
end
