FactoryGirl.define do
  factory :appointment do
    appointment_status "o"
    athena_appointment_type "MyString"
    leo_provider_id 1
    athena_provider_id 1
    leo_patient_id 1
    booked_by_user_id 1
    rescheduled_appointment_id 1
    duration 1
    appointment_date "2015-03-03"
    appointment_start_time "2015-03-03 18:12:45"
    frozenyn false
    leo_appointment_type "MyString"
    athena_appointment_type_id 1
    family_id 1
    athena_id 0
    athena_department_id 1
  end
end
