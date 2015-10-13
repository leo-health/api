FactoryGirl.define do
  factory :appointment do
    duration 30
    start_datetime Time.now
    appointment_status
    appointment_type
    practice
    association :provider, factory: [:user, :clinical]
    association :booked_by, factory: [:user, :guardian]
    after (:build) do |appointment|
      patient = FactoryGirl.build(:patient, family: appointment.booked_by.family)
      appointment.patient = patient
    end
  end
end
