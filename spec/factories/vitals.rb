FactoryGirl.define do
  factory :vital do
    athena_id 0
    taken_at { [1.years.ago, 2.years.ago, 3.years.ago, 4.years.ago, 5.years.ago ].sample }
    association :patient, factory: :patient

    trait :height do
      measurement 'HEIGHT'
      value { [1, 2, 3, 4, 5, 6, 7, 8, 9].sample }
    end

    trait :weight do
      measurement 'WEIGHT'
      value { [10, 20, 30, 40, 50, 60, 70, 80, 90].sample }
    end
  end
end
