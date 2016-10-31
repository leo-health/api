FactoryGirl.define do
  factory :survey do
    name { Faker::Lorem.word }
    survey_type { ['clinical' , 'feedback', 'tracking'].sample }
    reason 'test'
  end
end
