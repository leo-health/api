require 'rails_helper'

describe AnalyticsService do
  describe '.patients_with_appointments' do
    let!(:guardian_user) { create(:user, :guardian) }
    let(:patient) { create(:patient) }

    subject(:patients) { AnalyticsService.patients_with_appointments }

    context 'when NO appointments present' do
      it 'returns empty list' do
        expect(patients).to be_empty
      end
    end

    context 'when appointments are present' do
      let!(:time_range) { (1.week.ago.beginning_of_day)..(1.day.ago.end_of_day) }
      let!(:appointment_before_time_range)   { create(:appointment, booked_by: guardian_user, start_datetime: time_range.begin - 1.second) }
      let!(:appointment_within_time_range_1) { create(:appointment, booked_by: guardian_user, start_datetime: time_range.begin) }
      let!(:appointment_within_time_range_2) { create(:appointment, booked_by: guardian_user, start_datetime: time_range.begin) }
      let!(:appointment_after_time_range)    { create(:appointment, booked_by: guardian_user, start_datetime: time_range.end + 1.second) }

      context 'without time range provided' do
        it 'includes patients with appointments within given time range' do
          expect(patients.size).to eq(4)
          expect(patients).to include(appointment_within_time_range_1.patient,
                                      appointment_within_time_range_2.patient,
                                      appointment_before_time_range.patient,
                                      appointment_after_time_range.patient)
        end
      end

      context 'with time range provided' do
        subject(:patients) { AnalyticsService.patients_with_appointments(time_range: time_range) }

        it 'includes patients with appointments within given time range' do
          expect(patients.size).to eq(2)
          expect(patients).to include(appointment_within_time_range_1.patient,
                                      appointment_within_time_range_2.patient)
          expect(patients).to_not include(appointment_before_time_range.patient,
                                          appointment_after_time_range.patient)
        end
      end
    end
  end

  describe '.new_patients_enrolled_monthly' do
    let!(:april_patient_1) { create(:patient, created_at: '2016-04-11') }
    let!(:may_patient_1)   { create(:patient, created_at: '2016-05-11') }
    let!(:may_patient_2)   { create(:patient, created_at: '2016-05-12') }
    let!(:june_patient_1)  { create(:patient, created_at: '2016-06-11') }
    let!(:june_patient_2)  { create(:patient, created_at: '2016-06-12') }
    let!(:june_patient_3)  { create(:patient, created_at: '2016-06-13') }

    subject(:patients_by_month) { AnalyticsService.new_patients_enrolled_monthly }

    it 'returns proper grouped statistics' do
      expect(patients_by_month.size).to eq 3

      april = Time.find_zone('UTC').local(2016, 4, 1).utc
      may =   Time.find_zone('UTC').local(2016, 5, 1).utc
      june =  Time.find_zone('UTC').local(2016, 6, 1).utc

      expect(patients_by_month[april]).to eq 1
      expect(patients_by_month[may]).to   eq 2
      expect(patients_by_month[june]).to  eq 3
    end
  end

  describe '.appointments_booked' do
    let!(:time_range) { (1.week.ago)..(2.days.from_now) }

    let(:guardian_user_1) { create(:user, :guardian) }
    let(:guardian_user_2) { create(:user, :guardian) }
    let(:financial_user) { create(:user, :financial) }
    let(:clinical_support_user) { create(:user, :clinical_support) }
    let(:customer_service_user) { create(:user, :customer_service) }
    let(:clinical_user) { create(:user, :clinical) }

    subject(:appointments) { AnalyticsService.appointments_booked }

    context 'when NO appointments present' do
      it 'returns empty list' do
        expect(appointments).to be_empty
      end
    end

    context 'when appointments are present' do
      let!(:guardian_appointment_1)       { create(:appointment,
                                                   booked_by: guardian_user_1,
                                                   created_at: 2.weeks.ago.beginning_of_day,
                                                   start_datetime: 2.weeks.ago.beginning_of_day + 6.hours) }
      let!(:guardian_appointment_2)       { create(:appointment,
                                                   booked_by: guardian_user_2,
                                                   created_at: Time.zone.yesterday,
                                                   start_datetime: Time.zone.yesterday + 6.hours) }
      let!(:guardian_appointment_3)       { create(:appointment,
                                                   booked_by: guardian_user_1,
                                                   created_at: Time.zone.today,
                                                   start_datetime: Time.zone.today + 3.days) }
      let!(:guardian_appointment_4)       { create(:appointment,
                                                   booked_by: guardian_user_2,
                                                   created_at: 1.month.from_now.beginning_of_day,
                                                   start_datetime: 1.month.from_now.beginning_of_day + 6.hours) }
      let!(:guardian_appointment_5)       { create(:appointment,
                                                   booked_by: guardian_user_1,
                                                   created_at: 1.month.from_now.beginning_of_day - 1.minute,
                                                   start_datetime: 1.month.from_now.beginning_of_day + 1.minute) }
      let!(:financial_appointment)        { create(:appointment,
                                                   booked_by: financial_user,
                                                   created_at: Time.zone.today + 10.hours,
                                                   start_datetime: Time.zone.today + 12.hours) }
      let!(:clinical_support_appointment) { create(:appointment,
                                                   booked_by: clinical_support_user,
                                                   created_at: 1.month.from_now.beginning_of_day,
                                                   start_datetime: 1.month.from_now.beginning_of_day + 2.days) }
      let!(:customer_service_appointment) { create(:appointment,
                                                   booked_by: customer_service_user,
                                                   created_at: Time.zone.today - 1.hour,
                                                   start_datetime: Time.zone.today + 1.hour) }
      let!(:clinical_appointment)         { create(:appointment,
                                                   booked_by: clinical_user) }
      let!(:cancelled_appointment_1)        { create(:appointment, :cancelled,
                                                   booked_by: clinical_user) }
      let!(:cancelled_appointment_2)        { create(:appointment, :cancelled, 
                                                   booked_by: clinical_user) }
      let!(:cancelled_appointment_3)        { create(:appointment, :cancelled,
                                                   booked_by: clinical_user) }
      let!(:rescheduled_appointment)      { create(:appointment,
                                                   booked_by: customer_service_user,
                                                   rescheduled_id: cancelled_appointment_1.id) }

      context 'called without arguments' do
        it 'returns all appointments' do
          expect(appointments.size).to eq 12
        end

        it 'does return cancelled appointments' do
          expect(appointments).to include(cancelled_appointment_1, cancelled_appointment_2, cancelled_appointment_3)
          cancelled_count = AnalyticsService.appointments_cancelled.count-AnalyticsService.appointments_rescheduled.count
          expect(AnalyticsService.appointments_rescheduled.count).to eq(1)
          expect(AnalyticsService.appointments_cancelled.count).to eq(3)
          expect(cancelled_count).to eq(2)
        end

        it 'counts rescheduled appointments correctly' do
          expect(appointments).not_to include(rescheduled_appointment)
          expect(AnalyticsService.appointments_rescheduled).to include(rescheduled_appointment)
          expect(AnalyticsService.appointments_rescheduled.count).to eq(1)
        end
      end

      context 'called with role argument' do
        subject(:appointments) { AnalyticsService.appointments_booked(role: Role.guardian) }

        it 'returns only appointments booked by that role' do
          expect(appointments.size).to eq 5
          expect(appointments).to include(guardian_appointment_1,
                                          guardian_appointment_2,
                                          guardian_appointment_3,
                                          guardian_appointment_4,
                                          guardian_appointment_5)
          expect(appointments).not_to include(financial_appointment,
                                         clinical_support_appointment,
                                         customer_service_appointment,
                                         clinical_appointment)
        end
      end

      context 'called with time_range argument' do
        subject(:appointments) { AnalyticsService.appointments_booked(time_range: time_range) }

        it 'returns only appointments within that time range' do
          expect(appointments).to include(guardian_appointment_2,
                                          guardian_appointment_3,
                                          financial_appointment)
          expect(appointments).not_to include(guardian_appointment_1,
                                              guardian_appointment_4,
                                              guardian_appointment_5,
                                              clinical_support_appointment)
        end
      end

      context 'called with role and time_range arguments' do
        subject(:appointments) { AnalyticsService.appointments_booked(time_range: time_range, role: Role.guardian) }

        it 'returns only appointments within given time range booked by given role' do
          expect(appointments).to include(guardian_appointment_2,
                                          guardian_appointment_3)
          expect(appointments).not_to include(guardian_appointment_1,
                                              guardian_appointment_4,
                                              guardian_appointment_5,
                                              financial_appointment,
                                              clinical_support_appointment,
                                              customer_service_appointment,
                                              clinical_appointment)
        end
      end

      context 'called with same_day_only argument' do
        subject(:appointments) { AnalyticsService.appointments_booked(same_day_only: true) }

        it 'returns only appointments scheduled for the date of their creation' do
          expect(appointments).to include(guardian_appointment_1,
                                          guardian_appointment_2,
                                          guardian_appointment_4,
                                          financial_appointment)
          expect(appointments).not_to include(guardian_appointment_3,
                                              guardian_appointment_5,
                                              clinical_support_appointment,
                                              customer_service_appointment)
        end
      end

      context 'called with role and same_day_only arguments' do
        subject(:appointments) { AnalyticsService.appointments_booked(role: Role.guardian, same_day_only: true) }

        it 'returns only appointments scheduled for the date of their creation' do
          expect(appointments).to include(guardian_appointment_1,
                                          guardian_appointment_2,
                                          guardian_appointment_4)
          expect(appointments).not_to include(guardian_appointment_3,
                                              guardian_appointment_5,
                                              financial_appointment,
                                              clinical_support_appointment,
                                              customer_service_appointment)
        end
      end
    end
  end

  describe '.guardians_who_sent_messages' do
    let!(:time_range) { (1.week.ago)..(Time.zone.today) }

    let!(:guardian_with_sent_message_1) { create(:user, :guardian) }
    let!(:guardian_with_sent_message_2) { create(:user, :guardian) }
    let!(:guardian_with_sent_message_3) { create(:user, :guardian) }
    let!(:guardian_without_message)     { create(:user, :guardian) }
    let!(:non_guardian_1) { create(:user, :clinical_support) }
    let!(:non_guardian_2) { create(:user, :customer_service) }

    let!(:message_1_by_guardian_1)   { create(:message,
                                              sender: guardian_with_sent_message_1,
                                              created_at: 1.day.ago) }
    let!(:message_2_by_guardian_1)   { create(:message,
                                              sender: guardian_with_sent_message_1,
                                              created_at: 2.days.ago) }
    let!(:message_1_by_guardian_2)   { create(:message,
                                              sender: guardian_with_sent_message_2,
                                              created_at: 1.day.ago) }
    let!(:message_2_by_guardian_2)   { create(:message,
                                              sender: guardian_with_sent_message_2,
                                              created_at: 1.month.ago) }
    let!(:message_by_guardian_3)     { create(:message,
                                              sender: guardian_with_sent_message_3,
                                              created_at: 1.month.ago) }
    let!(:message_by_non_guardian_1) { create(:message,
                                              sender: non_guardian_1,
                                              created_at: 1.day.ago) }
    let!(:message_by_non_guardian_2) { create(:message,
                                              sender: non_guardian_2,
                                              created_at: 1.month.ago) }

    context 'without time range provided' do
      subject(:guardians_who_sent_messages) { AnalyticsService.guardians_who_sent_messages }

      it 'includes all and only guardians that sent at least one message' do
        expect(guardians_who_sent_messages).to include(guardian_with_sent_message_1,
                                                       guardian_with_sent_message_2,
                                                       guardian_with_sent_message_3)
        expect(guardians_who_sent_messages).not_to include(non_guardian_1,
                                                           non_guardian_2)
      end

      it 'includes each guardian only once' do
        expect(guardians_who_sent_messages.size).to eq 3
      end
    end

    context 'with time range provided' do
      subject(:guardians_who_sent_messages) { AnalyticsService.guardians_who_sent_messages(time_range: time_range) }

      it 'includes all and only guardians that sent at least one message within provided time range' do
        expect(guardians_who_sent_messages).to include(guardian_with_sent_message_1,
                                                       guardian_with_sent_message_2)
        expect(guardians_who_sent_messages).not_to include(guardian_with_sent_message_3,
                                                           non_guardian_1,
                                                           non_guardian_2)
      end

      it 'includes each guardian only once' do
        expect(guardians_who_sent_messages.size).to eq 2
      end
    end
  end

  describe '.cases_times_in_seconds' do
    let!(:time_range) { (1.week.ago.beginning_of_day)..(1.day.ago.end_of_day) }

    # Conversation 1: before time_range
    let!(:conversation_1) { create(:conversation, created_at: time_range.begin - 4.weeks) }
    let!(:case_time_1_conversation_1) { 2.hours }
    let!(:case_time_2_conversation_1) { 3.hours }

    let!(:message_1_conversation_1) { create(:message,
                                             conversation: conversation_1,
                                             created_at: conversation_1.created_at) }
    let!(:closure_note_1_conversation_1) { create(:closure_note,
                                                 conversation: conversation_1,
                                                 created_at: message_1_conversation_1.created_at + case_time_1_conversation_1) }
    let!(:message_2_conversation_1) { create(:message,
                                             conversation: conversation_1,
                                             created_at: closure_note_1_conversation_1.created_at + 3.days) }
    let!(:closure_note_2_conversation_1) { create(:closure_note,
                                                 conversation: conversation_1,
                                                 created_at: message_2_conversation_1.created_at + case_time_2_conversation_1) }
    let!(:message_3_conversation_1) { create(:message,
                                             conversation: conversation_1,
                                             created_at: closure_note_2_conversation_1.created_at + 5.days) }

    # Conversation 2: started before time_range, has a case within the range
    let!(:conversation_2) { create(:conversation, created_at: time_range.begin - 2.weeks) }
    let!(:case_time_1_conversation_2) { 90.minutes }
    let!(:case_time_2_conversation_2) { 60.minutes }

    let!(:message_1_conversation_2) { create(:message,
                                             conversation: conversation_2,
                                             created_at: conversation_2.created_at) }
    let!(:closure_note_1_conversation_2) { create(:closure_note,
                                                 conversation: conversation_2,
                                                 created_at: message_1_conversation_2.created_at + case_time_1_conversation_2) }
    let!(:message_2_conversation_2) { create(:message,
                                             conversation: conversation_2,
                                             created_at: time_range.begin + 10.minutes) }
    let!(:closure_note_2_conversation_2) { create(:closure_note,
                                                 conversation: conversation_2,
                                                 created_at: message_2_conversation_2.created_at + case_time_2_conversation_2) }

    # Conversation 3: within time_range
    let!(:conversation_3) { create(:conversation, created_at: time_range.begin + 2.hours) }
    let!(:case_time_1_conversation_3) { 80.minutes }
    let!(:case_time_2_conversation_3) { 50.minutes }

    let!(:message_1_conversation_3) { create(:message,
                                             conversation: conversation_3,
                                             created_at: conversation_3.created_at) }
    let!(:closure_note_1_conversation_3) { create(:closure_note,
                                                 conversation: conversation_3,
                                                 created_at: message_1_conversation_3.created_at + case_time_1_conversation_3) }
    let!(:message_2_conversation_3) { create(:message,
                                             conversation: conversation_3,
                                             created_at: closure_note_1_conversation_3.created_at + 1.hour) }
    let!(:closure_note_2_conversation_3) { create(:closure_note,
                                                 conversation: conversation_3,
                                                 created_at: message_2_conversation_3.created_at + case_time_2_conversation_3) }

    # Conversation 4: started within time_range, has cases after the range
    let!(:conversation_4) { create(:conversation, created_at: time_range.end - 1.day) }
    let!(:case_time_1_conversation_4) { 75.minutes }
    let!(:case_time_2_conversation_4) { 45.minutes.hours }

    let!(:message_1_conversation_4) { create(:message,
                                             conversation: conversation_4,
                                             created_at: conversation_4.created_at) }
    let!(:closure_note_1_conversation_4) { create(:closure_note,
                                                 conversation: conversation_4,
                                                 created_at: message_1_conversation_4.created_at + case_time_1_conversation_4) }
    let!(:message_2_conversation_4) { create(:message,
                                             conversation: conversation_4,
                                             created_at: time_range.end + 1.hour) }
    let!(:closure_note_2_conversation_4) { create(:closure_note,
                                                 conversation: conversation_4,
                                                 created_at: message_2_conversation_4.created_at + case_time_2_conversation_4) }

    # Conversation 5: after time_range
    let!(:conversation_5) { create(:conversation, created_at: time_range.end + 4.weeks) }
    let!(:case_time_1_conversation_5) { 11.hours }
    let!(:case_time_2_conversation_5) { 14.hours }

    let!(:message_1_conversation_5) { create(:message,
                                             conversation: conversation_5,
                                             created_at: conversation_5.created_at + 1.week) }
    let!(:closure_note_1_conversation_5) { create(:closure_note,
                                                  conversation: conversation_5,
                                                  created_at: message_1_conversation_5.created_at + case_time_1_conversation_5) }
    let!(:message_2_conversation_5) { create(:message,
                                             conversation: conversation_5,
                                             created_at: conversation_5.created_at + 2.weeks) }
    let!(:closure_note_2_conversation_5) { create(:closure_note,
                                                  conversation: conversation_5,
                                                  created_at: message_2_conversation_5.created_at + case_time_2_conversation_5) }

    # Conversation 6: has cases that are partially within time_range
    let!(:conversation_6) { create(:conversation, created_at: time_range.begin - 6.minutes) }
    let!(:case_time_1_conversation_6) { 12.minutes }
    let!(:case_time_2_conversation_6) { 14.minutes }
    let!(:case_time_3_conversation_6) { 16.minutes }

    let!(:message_1a_conversation_6) { create(:message,
                                             conversation: conversation_6,
                                             created_at: conversation_6.created_at) }
    let!(:message_1b_conversation_6) { create(:message,
                                             conversation: conversation_6,
                                             created_at: message_1a_conversation_6.created_at + case_time_1_conversation_6 - 1.minute) }
    let!(:closure_note_1_conversation_6) { create(:closure_note,
                                                  conversation: conversation_6,
                                                  created_at: message_1a_conversation_6.created_at + case_time_1_conversation_6) }
    let!(:message_2_conversation_6) { create(:message,
                                             conversation: conversation_6,
                                             created_at: time_range.begin + 6.hours) }
    let!(:closure_note_2_conversation_6) { create(:closure_note,
                                                  conversation: conversation_6,
                                                  created_at: message_2_conversation_6.created_at + case_time_2_conversation_6) }
    let!(:message_3_conversation_6) { create(:message,
                                             conversation: conversation_6,
                                             created_at: time_range.end - 8.minutes) }
    let!(:closure_note_3_conversation_6) { create(:closure_note,
                                                  conversation: conversation_6,
                                                  created_at: message_3_conversation_6.created_at + case_time_3_conversation_6) }

    context 'without time range provided' do
      subject(:cases_times_in_seconds) { AnalyticsService.cases_times_in_seconds }

      it 'returns all existing cases times' do
        expect(cases_times_in_seconds.size).to eq 13
        expect(cases_times_in_seconds).to include(case_time_1_conversation_1.to_f,
                                                  case_time_2_conversation_1.to_f,
                                                  case_time_1_conversation_2.to_f,
                                                  case_time_2_conversation_2.to_f,
                                                  case_time_1_conversation_3.to_f,
                                                  case_time_2_conversation_3.to_f,
                                                  case_time_1_conversation_4.to_f,
                                                  case_time_2_conversation_4.to_f)
      end

    end

    context 'with time range provided' do
      subject(:cases_times_in_seconds) { AnalyticsService.cases_times_in_seconds(time_range: time_range) }

      it 'returns times for all cases within the time_range' do
        expect(cases_times_in_seconds.size).to eq 5
      end

      context 'for conversations having all cases before time_range' do
        it 'does not return any times' do
          expect(cases_times_in_seconds).not_to include(case_time_1_conversation_1.to_f,
                                                        case_time_2_conversation_1.to_f)
        end
      end

      context 'for conversations started before time_range but having cases within time range' do
        it 'does not return times for cases from before time_range'  do
          expect(cases_times_in_seconds).not_to include(case_time_1_conversation_2.to_f)
        end
        it 'returns times for cases within time_range' do
          expect(cases_times_in_seconds).to include(case_time_2_conversation_2.to_f)
        end
      end

      context 'for conversations with all cases within time_range' do
        it 'returns all cases' do
          expect(cases_times_in_seconds).to include(case_time_1_conversation_3.to_f,
                                                    case_time_2_conversation_3.to_f)
        end
      end

      context 'for conversations started within time_range but having cases after time range' do
        it 'returns times for cases within time_range' do
          expect(cases_times_in_seconds).to include(case_time_1_conversation_4.to_f)
        end
        it 'does not return times for cases from after time_range'  do
          expect(cases_times_in_seconds).not_to include(case_time_2_conversation_4.to_f)
        end
      end

      context 'for conversations having all cases after time_range' do
        it 'does not return any times' do
          expect(cases_times_in_seconds).not_to include(case_time_1_conversation_5.to_f,
                                                        case_time_2_conversation_5.to_f)
        end
      end

      context 'for conversations having cases that are partially within time_range' do
        it 'returns cases that are entirely within time_range' do
          expect(cases_times_in_seconds).to include(case_time_2_conversation_6.to_f)
        end

        it 'does not return cases that are only partially within time_range' do
          expect(cases_times_in_seconds).not_to include(case_time_1_conversation_6.to_f,
                                                        case_time_3_conversation_6.to_f)
        end
      end
    end
  end
end
