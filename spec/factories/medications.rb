FactoryGirl.define do
  factory :medication do
    association :health_record, strategy: :build
  end
end
