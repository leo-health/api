FactoryGirl.define do
  factory :photo do
    patient_id 0
    image ""
    taken_at DateTime.now
  end
end
