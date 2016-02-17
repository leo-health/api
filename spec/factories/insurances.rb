FactoryGirl.define do
  factory :insurance do
    athena_id 0
    plan_name "insurance_plan"
    plan_phone "000-000-0000"
    plan_type "plan_type"
    policy_number "policy_number"
    holder_ssn "000-00-0000"
    holder_sex ["M", "F"].sample
    holder_last_name "holder_last_name"
    holder_first_name "holder_first_name"
    holder_middle_name "M"
    holder_address_1 "holder_address_1"
    holder_address_2 "holder_address_2"
    holder_city "holder_city"
    holder_state "CA"
    holder_zip "90210"
    holder_country "USA"
    primary 1
    holder_birth_date 40.years.ago
    irc_name "irc_name"
    association :patient, factory: :patient
  end
end
