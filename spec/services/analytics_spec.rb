require 'rails_helper'

describe Analytics do
  describe '#patients_with_appointments_in' do
    let!(:guardian_user) { create(:user, :guardian) }

    subject(:patients) { Analytics.patients_with_appointments_in(time_range) }

    context 'no appointments' do
      let(:time_range) { 12.months.ago..Time.now }

      it 'empty list' do
        expect(patients).to be_empty
      end
    end

    context 'appointments' do
      let(:time_range) { 12.months.ago..6.months.ago }

      let!(:appointment_before_time_range)   { create(:appointment, booked_by: guardian_user, start_datetime: time_range.begin - 1.second) }
      let!(:appointment_within_time_range_1) { create(:appointment, booked_by: guardian_user, start_datetime: time_range.begin) }
      let!(:appointment_within_time_range_2) { create(:appointment, booked_by: guardian_user, start_datetime: time_range.end) }
      let!(:appointment_after_time_range)    { create(:appointment, booked_by: guardian_user, start_datetime: time_range.end + 1.second) }

      it 'includes patients with appointments within given time range' do
        expect(patients.count).to eq(2)

        expect(patients).to include(appointment_within_time_range_1.patient)
        expect(patients).to include(appointment_within_time_range_1.patient)

        expect(patients).to_not include(appointment_before_time_range.patient)
        expect(patients).to_not include(appointment_after_time_range.patient)
      end
    end
  end

  describe '#new_patients_enrolled_in_practice' do
    let!(:april_patient_1) { create(:patient, created_at: '2016-04-11') }
    let!(:may_patient_1)   { create(:patient, created_at: '2016-05-11') }
    let!(:may_patient_2)   { create(:patient, created_at: '2016-05-12') }
    let!(:june_patient_1)  { create(:patient, created_at: '2016-06-11') }
    let!(:june_patient_2)  { create(:patient, created_at: '2016-06-12') }
    let!(:june_patient_3)  { create(:patient, created_at: '2016-06-13') }

    describe '.patients_with_appointments_in' do
      subject(:patients_by_month) { Analytics.new_patients_enrolled_in_practice }

      it 'empty list' do
        expect(patients_by_month.size).to eq 3

        april = Time.find_zone('UTC').local(2016, 4, 1).utc
        may =   Time.find_zone('UTC').local(2016, 5, 1).utc
        june =  Time.find_zone('UTC').local(2016, 6, 1).utc

        expect(patients_by_month[april]).to eq 1
        expect(patients_by_month[may]).to   eq 2
        expect(patients_by_month[june]).to  eq 3
      end

    end
  end

  describe '#visits_booked_by' do
    let(:time_range) { Date.yesterday..Date.tomorrow }

    let!(:guardian_appointment)         { create(:appointment, booked_by: create(:user, :guardian)) }
    let!(:financial_appointment)        { create(:appointment, booked_by: create(:user, :financial)) }
    let!(:clinical_support_appointment) { create(:appointment, booked_by: create(:user, :clinical_support)) }
    let!(:customer_service_appointment) { create(:appointment, booked_by: create(:user, :customer_service)) }
    let!(:clinical_appointment)         { create(:appointment, booked_by: create(:user, :clinical)) }

    subject(:visits) { Analytics.visits_booked_by(role, time_range) }

    context 'guardian' do
      let(:role) { Role.find_by(name: :guardian) }

      it 'list of visits booked by guardian user' do
        expect(visits.size).to eq 1
        expect(visits).to include guardian_appointment
      end
    end

    context 'financial' do
      let(:role) { Role.find_by(name: :financial) }

      it 'list of visits booked by financial user' do
        expect(visits.size).to eq 1
        expect(visits).to include financial_appointment
      end
    end

    context 'clinical_support' do
      let(:role) { Role.find_by(name: :clinical_support) }

      it 'list of visits booked by clinical_support user' do
        expect(visits.size).to eq 1
        expect(visits).to include clinical_support_appointment
      end
    end

    context 'customer_service' do
      let(:role) { Role.find_by(name: :customer_service) }

      it 'list of visits booked by customer_service user' do
        expect(visits.size).to eq 1
        expect(visits).to include customer_service_appointment
      end
    end

    context 'clinical' do
      let(:role) { Role.find_by(name: :clinical) }

      it 'list of visits booked by clinical user' do
        expect(visits.size).to eq 1
        expect(visits).to include clinical_appointment
      end
    end
  end

  describe '.messages_sent_by_guardians' do
    let(:time_range) { Date.yesterday..Date.tomorrow }

    let(:guardian_user_with_sent_message_1) { create(:user, :guardian) }
    let(:guardian_user_with_sent_message_2) { create(:user, :guardian) }
    let(:guardian_user_without_message)     { create(:user, :guardian) }
    let(:non_guardian_user_1) { create(:user, :clinical_support) }
    let(:non_guardian_user_2) { create(:user, :customer_service) }

    let!(:message_by_guardian_1_1)        { create(:message, sender: guardian_user_with_sent_message_1) }
    let!(:message_by_guardian_1_2)        { create(:message, sender: guardian_user_with_sent_message_1) }
    let!(:message_by_guardian_2)          { create(:message, sender: guardian_user_with_sent_message_2) }
    let!(:message_by_non_guardian_user_1) { create(:message, sender: non_guardian_user_1) }
    let!(:message_by_non_guardian_user_2) { create(:message, sender: non_guardian_user_2) }

    subject(:guardians_who_sent_messages) { Analytics.guardians_who_sent_messages(time_range) }

    it 'includes all guardians that sent at least one message' do
      expect(guardians_who_sent_messages.count).to eq 2

      expect(guardians_who_sent_messages).to include guardian_user_with_sent_message_1
      expect(guardians_who_sent_messages).to include guardian_user_with_sent_message_2
    end
  end
end
