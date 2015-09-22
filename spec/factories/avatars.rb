FactoryGirl.define do
  factory :avatar do
    avatar { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'Zen-Dog1.jpg')) }
    association :owner, factory: :patient, strategy: :build
  end
end
