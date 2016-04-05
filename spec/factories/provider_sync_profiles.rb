FactoryGirl.define do
  factory :provider_sync_profile, :class => 'ProviderSyncProfile' do
    after(:build) do |provider_sync_profile|
      provider_sync_profile.provider ||= FactoryGirl.build(:user, :clinical, provider_sync_profile: provider_sync_profile)
    end
  end
end
