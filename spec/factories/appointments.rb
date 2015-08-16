FactoryGirl.define do
  factory :appointment do
    duration 30
    start_datetime Time.now
    status_id 1 #not sure what is the range of this entry
    status "need copy"
    association :appointment_type
    association :provider, factory: [:user, :clinical]
    association :booked_by, factory: [:user, :guardian]
    association :patient
  end
end
