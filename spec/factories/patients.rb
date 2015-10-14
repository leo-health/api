FactoryGirl.define do
  factory :patient do
    first_name { ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name { ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    birth_date { 10.years.ago.to_s }
    sex { ['M', 'F'].sample }
    family
    association :role, factory: [:role, :patient]
  end
end
