FactoryGirl.define do
  factory :user_link_preview do
    association :user
    association :link_preview
  end
end
