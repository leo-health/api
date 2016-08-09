require 'rails_helper'

RSpec.describe Practice, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:staff).class_name('User') }
    it{ is_expected.to have_many(:guardians).class_name('User') }
    it{ is_expected.to have_many(:appointments) }
    it{ is_expected.to have_many(:practice_schedules) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "in_office_hours?" do
    let(:practice){ create(:practice) }
    let!(:practice_schedule){ create(:practice_schedule, practice: practice) }

    context "practice is open now" do
      before do
        Timecop.freeze(Time.zone.local(2015, 12, 10, 9, 1, 0))
      end

      after do
        Timecop.return
      end

      it "should return true" do
        expect(practice.in_office_hours?).to eq(true)
      end
    end

    context "practice is closed now" do
      before do
        Timecop.freeze(Time.zone.local(2015, 12, 10, 17, 1, 0))
      end

      after do
        Timecop.return
      end

      it "should return false" do
        expect(practice.in_office_hours?).to eq(false)
      end
    end
  end

  describe "#subscribe_to_athena" do
    let(:practice){create(:practice)}
    before do
      @practice = practice
    end

    context "after creating a practice" do
      it "calls subscribe_to_athena" do
        expect(@practice).to callback(:subscribe_to_athena).after(:commit).on(:create)
      end
    end

    describe ".subscribe_to_athena" do
      context "a SyncAppointmentsJob job already exists for this practice" do
        # ????: The job is created as a side effect by calling practice in before block.
        # ????: Is there a better way to isolate these things?
        # TODO: come back and make these tests better after gaining more experience with rspec
        it "does not add a job" do
          expect{ @practice.subscribe_to_athena }.to change {
            Delayed::Job.where(queue: SyncAppointmentsJob.queue_name, owner:@practice).count
          }.by(0)
        end
      end

      context "no SyncAppointmentsJob job exists for this practice" do
        it "adds a SyncAppointmentsJob to the queue" do
          @practice.subscribe_to_athena
          expect(Delayed::Job.where(queue: SyncPracticeJob.queue_name, owner:@practice).count).to be(1)
        end
      end
    end
  end

  describe "on call" do
    let(:practice){create(:practice)}
    let(:oncall_provider){ create(:user, :clinical, practice: practice) }
    let!(:staff_profile){ create(:staff_profile, staff: oncall_provider, sms_enabled: false, on_call: true) }

    describe "#oncall_providers" do
      it "should return oncall providers of the pratice" do
        expect(practice.oncall_providers).to eq([oncall_provider])
      end
    end

    describe "#available?" do
      it "should return true or false on any provider is oncall" do
        expect(practice.available?).to eq(true)
      end
    end

    describe "#start_after_office_hours" do
      it "should update sms_enabled to true and on_call to false, then broadcast the changes" do
        expect(practice).to receive(:broadcast_practice_availability)
        practice.start_after_office_hours
      end
    end

    describe "#start_in_office_hours" do
      it "should update sms_enabled to false and on_call to true, then broadcast the changes" do
        expect(practice).to receive(:broadcast_practice_availability)
        practice.start_in_office_hours
      end
    end
  end

  describe "office hours" do
    describe "#start_after_office_hours" do

    end

    describe "#start_in_office_hours" do

    end
  end
end
