FactoryGirl.define do
  factory :conversation do
    association :family

    factory :conversation_with_staff do
      after(:create) do |instance|
        create(:user, :father, family: instance)
        create(:user, :mother, family: instance)
      end
    end
  end
end
