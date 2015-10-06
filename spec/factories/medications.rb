FactoryGirl.define do
  factory :medication do
    athena_id 0
    medication { ["med 1", "med 2", "med 3"].sample }
    sig "sig"
    note "note"
    started_at { [ 1.year.ago, 2.years.ago, 3.years.ago, 4.years.ago, DateTime.now ].sample }
    ordered_at { [ 1.year.ago, 2.years.ago, 3.years.ago, 4.years.ago, DateTime.now ].sample }
    association :patient, factory: :patient
  end

end
