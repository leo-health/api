FactoryGirl.define do
  factory :appointment do
    duration 30
    start_datetime Time.now
    association :appointment_status
    association :appointment_type
    association :provider, factory: [:user, :clinical]
    association :booked_by, factory: [:user, :guardian]
    after (:build) do |appointment|
      patient = FactoryGirl.create(:patient, family: appointment.booked_by.family)
      appointment.patient = patient
    end
  end
end
