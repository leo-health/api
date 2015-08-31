FactoryGirl.define do
  factory :allergy do
    association :health_record, strategy: :build
  end
end
