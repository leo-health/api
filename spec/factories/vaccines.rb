FactoryGirl.define do
  factory :vaccine do
    vaccine 	"Hepatitus B"
    administered_at 	Time.now
    association :patient
  end
end
