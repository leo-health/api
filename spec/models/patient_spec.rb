require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe 'relations' do
    it{ is_expected.to belong_to(:family) }
    it{ is_expected.to have_many(:medications) }
    it{ is_expected.to have_many(:photos) }
    it{ is_expected.to have_many(:vaccines) }
    it{ is_expected.to have_many(:vitals) }
    it{ is_expected.to have_many(:insurances) }
    it{ is_expected.to have_many(:avatars) }
    it{ is_expected.to have_many(:forms) }

    describe "has many appointments" do
      let!(:patient) { create(:patient) }
      let(:provider){ create(:provider) }
      let(:guardian){ create(:user, :guardian) }

      let!(:cancelled_appointment){ create(:appointment, :cancelled, booked_by: guardian, provider: provider, start_datetime: 1.minutes.ago) }
      let!(:checked_in_appointment){ create(:appointment, :checked_in, booked_by: guardian, provider: provider, start_datetime: 2.minutes.ago) }
      let!(:charge_entered_appointment){ create(:appointment, :charge_entered, booked_by: guardian, provider: provider, start_datetime: 3.minutes.ago) }
      let!(:open_appointmet){ create(:appointment, :open, booked_by: guardian, provider: provider) }

      before do
        patient.update_attributes(family: guardian.family)
        Appointment.update_all(patient_id: patient.id)
      end

      it "should return booked appointments for of patient" do
        expect(patient.appointments.sort).to eq([checked_in_appointment, charge_entered_appointment])
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:birth_date) }
    it { is_expected.to validate_presence_of(:sex) }
    it { is_expected.to validate_presence_of(:family) }
  end

  describe '#current_avatar' do
    let(:patient) { create(:patient) }
    let!(:old_avatar){ create(:avatar, owner: patient)}
    let!(:current_avatar){ create(:avatar, owner: patient)}

    it 'should return the current_avatar' do
      expect( patient.current_avatar ).to eq(current_avatar)
    end
  end

  describe "sync jobs" do
    let!(:patient) { create(:patient) }

    before do
      @patient = patient
      patient.family.renew_membership!
    end

    context 'before syncing the patient' do
      it "calls post_to_athena" do
        expect(@patient).to callback(:post_to_athena).after(:commit)
      end
    end

    describe ".post_to_athena" do
      context "the job already exists" do
        it "does not add a PostPatientJob to the queue" do
          @patient.post_to_athena
          expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(1)
        end
      end

      context "the job does not exist" do
        before do
          Delayed::Job.where(queue: PostPatientJob.queue_name).destroy_all
        end

        it "adds a PostPatientJob to the queue" do
          @patient.post_to_athena
          expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(1)
        end
      end
    end

    context 'after syncing the patient' do
      it "calls subscribe_to_athena" do
        @patient.athena_id = 1
        expect(@patient).to callback(:subscribe_to_athena).after(:commit)
        @patient.save!
      end
    end

    describe ".subscribe_to_athena" do
      context "patient has not been synced" do
        it "adds a PostPatientJob to the queue" do
          @patient.subscribe_to_athena
          expect(Delayed::Job.where(queue: PostPatientJob.queue_name).count).to be(1)
        end
      end

      context "patient has been synced" do
        it "adds a SyncPatientJob to the queue" do
          @patient.athena_id = 1
          @patient.subscribe_to_athena
          expect(Delayed::Job.where(queue: SyncPatientJob.queue_name).count).to be(1)
        end
      end
    end
  end

  describe ".enqueue_milestone_content_delivery_job" do
    before :each do
      @patient = create(:patient)
    end

    it "gets called on create" do
      expect(@patient).to callback(:enqueue_milestone_content_delivery_job).after(:commit).on(:create)
    end

    it "enqueues a MilestoneContentJob" do
      expect(Delayed::Job.where(queue: "send_milestone_link_preview").count).to be(1)
    end
  end

  describe "milestone content" do
    before do
      ages_for_milestone_content = [1, 2, 3, 4, 5, 6, 9, 12, 15, 18, 24, 30, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 168, 180, 216, 228, 264]
      ages_for_milestone_content.each_with_index do |age, index|
        create(:link_preview, :milestone_content,
          id: index + 2,
          age_of_patient_in_months: age,
          title: "#{age} month milestone"
        )
      end

      @family = create(:family_with_members)
      @patient = @family.patients.first
    end

    describe ".ensure_current_milestone_link_preview" do
      context "patient was just born" do
        before do
          @patient.update_attributes(birth_date: Date.today)
        end

        it "does not send a UserLinkPreview" do
          @patient.ensure_current_milestone_link_preview
          expect(UserLinkPreview.count).to eq(0)
        end
      end

      context "patient has a milestone today" do
        before do
          @patient.update_attributes(birth_date: 1.year.ago)
        end

        context "UserLinkPreview exists" do
          it "changes nothing" do
            @family.guardians.each do |guardian|
              create(:user_link_preview,
                user: guardian,
                owner: @patient,
                link_preview: LinkPreview.find_by(age_of_patient_in_months: 12)
              )
            end
            expect(UserLinkPreview.count).to eq(2)
            @patient.ensure_current_milestone_link_preview
            expect(UserLinkPreview.count).to eq(2)
          end
        end

        context "UserLinkPreview does not exist" do
          it "creates one" do
            expect(UserLinkPreview.count).to eq(0)
            @patient.ensure_current_milestone_link_preview
            expect(UserLinkPreview.count).to eq(2)
          end
        end
      end

      context "patient had a milestone last week" do
        before do
          @patient.update_attributes(birth_date: 105.weeks.ago)
        end

        context "UserLinkPreview exists" do
          it "changes nothing" do
            @family.guardians.each do |guardian|
              create(:user_link_preview,
                user: guardian,
                owner: @patient,
                link_preview: LinkPreview.find_by(age_of_patient_in_months: 24)
              )
            end
            expect(UserLinkPreview.count).to eq(2)
            @patient.ensure_current_milestone_link_preview
            expect(UserLinkPreview.count).to eq(2)
          end
        end

        context "old UserLinkPreview exists" do
          it "deletes the old ones and creates new ones" do
            @family.guardians.each do |guardian|
              create(:user_link_preview,
                user: guardian,
                owner: @patient,
                link_preview: LinkPreview.find_by(age_of_patient_in_months: 12)
              )
            end
            expect(UserLinkPreview.count).to eq(2)
            @patient.ensure_current_milestone_link_preview
            expect(UserLinkPreview.count).to eq(2)

            correct_link_preview = LinkPreview.find_by(age_of_patient_in_months: 24)
            expect(
              UserLinkPreview.where(owner: @patient).map(&:link_preview)
            ).to eq([correct_link_preview, correct_link_preview])
          end
        end
      end
    end

    describe ".time_of_next_milestone" do
      context "patient is 6 months old" do
        before do
          Timecop.freeze(Time.zone.local(2015, 12, 10, 9, 1, 0))
          @patient.update_attributes(birth_date: 6.months.ago)
        end

        it "returns 9 months after birth_date" do
          next_milestone_date = @patient.time_of_next_milestone
          expected_next_milestone_date = @patient.birth_date + 9.months
          expect(next_milestone_date).to eq(expected_next_milestone_date)
        end
      end

      context "patient was born on a leap day" do
        before do
          @patient.update_attributes(birth_date: Date.new(2008, 2, 29))
        end

        context "second monthiversary" do
          before do
            Timecop.freeze(Time.zone.local(2008, 4, 1))
          end

          it "returns Feb 29" do
            next_milestone_date = @patient.time_of_next_milestone
            expected_next_milestone_date = Date.new(2008, 4, 29)
            expect(next_milestone_date).to eq(expected_next_milestone_date)
          end
        end

        context "Today is Feb 1 of next leap year" do
          before do
            Timecop.freeze(Time.zone.local(2012, 2, 1))
          end

          it "returns Feb 29" do
            next_milestone_date = @patient.time_of_next_milestone
            expected_next_milestone_date = Date.new(2012, 2, 29)
            expect(next_milestone_date).to eq(expected_next_milestone_date)
          end
        end

        context "Today is Feb 1 of a non-leap year" do
          before do
            Timecop.freeze(Time.zone.local(2013, 2, 1))
          end

          it "returns Feb 29" do
            next_milestone_date = @patient.time_of_next_milestone
            expected_next_milestone_date = Date.new(2013, 2, 28)
            expect(next_milestone_date).to eq(expected_next_milestone_date)
          end
        end
      end
    end
  end
end
