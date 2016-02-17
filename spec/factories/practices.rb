FactoryGirl.define do
  factory :practice do
    name "practice"
    city "New York"
    state "NY"
    zip "10011"

    after(:create) do |practice|
      create(:practice_schedule, practice: practice)
    end
  end
end
