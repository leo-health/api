FactoryGirl.define do
  factory :medication do
      athena_id 0
      medication "medication"
      sig "sig"
      patient_note "patient_note"
      started_at DateTime.now
      ordered_at DateTime.now
  end
end
