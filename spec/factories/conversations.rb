FactoryGirl.define do
  factory :conversation do
    association :family, strategy: :build
    state :closed
  end
end
