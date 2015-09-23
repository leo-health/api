FactoryGirl.define do
  factory :avatar do
    avatar { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'Zen-Dog1.jpg')) }
    association :owner, factory: :patient, strategy: :build

    after(:create) do |avatar|
      avatar.avatar = avatar
      avatar.save!
    end
  end
end
