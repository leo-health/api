FactoryGirl.define do
  factory :question do
    body 'To be or not to be?'
    order 1
    question_type { ['single select', 'multi select', 'single line', 'multi line', 'rating/numerical'].sample }
    association :survey
  end
end
