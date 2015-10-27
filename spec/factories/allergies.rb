FactoryGirl.define do
  factory :allergy, :class => 'Allergy' do
    athena_id 0
    allergen { ["Pollen", "Dust", "Peanuts"].sample }
    onset_at { [ 1.year.ago, 2.years.ago, 3.years.ago, 4.years.ago, DateTime.now ].sample }
    association :patient, factory: :patient
  end

end
