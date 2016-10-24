FactoryGirl.define do
  factory :choice do
    association :question
    choice_type {['unstructured', 'structured'].sample}
  end
end
