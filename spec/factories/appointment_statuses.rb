FactoryGirl.define do
  factory :appointment_status do
    id    0
    name "cancelled"
    initialize_with { AppointmentStatus.find_or_create_by(id: id)}

    trait :cancelled do
      id 0
      description "cancelled"
      status "x"
    end

    trait :checked_in do
      id 1
      description "Checked In"
      status "2"
    end

    trait :checked_out do
      id 2
      description "Checked Out"
      status "3"
    end

    trait :charge_entered do
      id 3
      description "Charge Enterted"
      status "4"
    end

    trait :future do
      id 4
      description "Future"
      status "f"
    end

    trait :open do
      id 5
      description "Open"
      status "o"
    end
  end
end
