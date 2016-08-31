FactoryGirl.define do
  factory :vaccine do
    vaccine 	"diphtheria, tetanus toxoids and acellular pertussis vaccine, haemophilus influenzae type b conjugate, and poliovirus vaccine, inactivated (DTaP-Hib-IPV)"
    administered_at 	Time.now
    association :patient
  end
end
