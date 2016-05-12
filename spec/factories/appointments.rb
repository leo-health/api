FactoryGirl.define do
  factory :appointment do
    duration 30
    start_datetime Time.now
    appointment_status
    appointment_type
    practice
    association :provider, factory: [:provider]
    association :booked_by, factory: [:user, :guardian]

    trait :cancelled do
      association :appointment_status, factory: [:appointment_status, :cancelled]
    end

    trait :checked_in do
      association :appointment_status, factory: [:appointment_status, :checked_in]
    end

    trait :checked_out do
      association :appointment_status, factory: [:appointment_status, :checked_out]
    end

    trait :charge_entered do
      association :appointment_status, factory: [:appointment_status, :charge_entered]
    end

    trait :future do
      association :appointment_status, factory: [:appointment_status, :future]
    end

    trait :open do
      association :appointment_status, factory: [:appointment_status, :open]
    end

    after (:build) do |appointment|
      patient = FactoryGirl.build(:patient, family: appointment.booked_by.family)
      appointment.patient = patient
    end
  end
end
