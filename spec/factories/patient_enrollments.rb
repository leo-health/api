FactoryGirl.define do
  factory :patient_enrollment do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    birth_date  { 5.years.ago }
    sex					{ ['M', 'F'].sample }
    association :guardian_enrollment, factory: :enrollment
  end
end
