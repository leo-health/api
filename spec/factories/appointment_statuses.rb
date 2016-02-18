FactoryGirl.define do
  factory :appointment_status do
    description "Future"
    status "f"
    initialize_with { AppointmentStatus.find_or_create_by(status: status)}

    trait :cancelled do
      description "Cancelled"
      status "x"
    end

    trait :checked_in do
      description "Checked In"
      status "2"
    end

    trait :checked_out do
      description "Checked Out"
      status "3"
    end

    trait :charge_entered do
      description "Charge Entered"
      status "4"
    end

    trait :future do
      description "Future"
      status "f"
    end

    trait :open do
      description "Open"
      status "o"
    end
  end
end
