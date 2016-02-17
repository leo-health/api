FactoryGirl.define do
  factory :form do
    id ""
    patient
    title "Form_Title"
    notes "Description of what the form is for"
    association :submitted_by, factory: :user
    association :completed_by, factory: :user
    status "new"
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'Zen-Dog1.png')) }
  end
end
