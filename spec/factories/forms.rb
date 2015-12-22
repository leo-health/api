FactoryGirl.define do
  factory :form do
    id ""
    patient
    title "Form_Title"
    notes "Description of what the form is for"
    association :submitted_by, factory: :user
    association :completed_by, factory: :user
    status "new"
  end

end
