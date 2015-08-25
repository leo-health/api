FactoryGirl.define do
  factory :health_record do
    athena_id 1
    association :patient, strategy: :build
  end
end
