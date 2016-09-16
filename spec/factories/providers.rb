FactoryGirl.define do
  factory :provider do
    after(:build) do |provider|
      provider.user ||= FactoryGirl.build(:user, :clinical, provider: provider)
      provider.first_name = provider.user.first_name
      provider.last_name = provider.user.last_name
    end
  end
end
