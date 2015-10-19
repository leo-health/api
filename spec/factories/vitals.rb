FactoryGirl.define do
  factory :vital do
    athena_id 0
    taken_at { [1.years.ago, 2.years.ago, 3.years.ago, 4.years.ago, 5.years.ago ].sample }
    association :patient, factory: :patient

    trait :height do
      measurement 'VITALS.HEIGHT'
      value { [25, 50, 75, 100, 125, 150].sample }
    end

    trait :weight do
      measurement 'VITALS.WEIGHT'
      value { [10, 20, 30, 40, 50, 60].sample }
    end
  end
end
