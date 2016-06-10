FactoryGirl.define do
  factory :provider do
    after(:build) do |provider|
      provider.user ||= FactoryGirl.build(:user, :clinical, provider: provider)
    end
  end
end
