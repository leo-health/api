FactoryGirl.define do
  factory :survey do
    name { Faker::Lorem.word }
    survey_type { ['clinical' , 'feedback', 'tracking'].sample }
    reason 'test'
    display_name 'display_name'
  end
end
