FactoryGirl.define do
  factory :allergy, :class => 'Allergy' do
    patient_id 1
    athena_id 1
    allergen "Pollen"
    onset_at DateTime.now
  end

end
