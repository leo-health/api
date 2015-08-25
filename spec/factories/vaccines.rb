FactoryGirl.define do
  factory :vaccine do
    association :health_record, strategy: :build
  end
end
