FactoryGirl.define do
  factory :conversation do
    association :family, strategy: :build
    status :closed
  end
end
