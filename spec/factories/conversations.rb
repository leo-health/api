FactoryGirl.define do
  factory :conversation do
    association :family, factory: :family
  end
end
