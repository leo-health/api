FactoryGirl.define do
  factory :family do
    association :conversation

    factory :family_with_members do
      after(:create) do |instance|
        create(:user, :father, family: instance)
        create(:user, :mother, family: instance)
        create(:patient, family: instance)
        create(:patient, family: instance)
        create(:patient, family: instance)
      end
    end
  end
end
