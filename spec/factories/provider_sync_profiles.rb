FactoryGirl.define do
  factory :provider_sync_profile, :class => 'ProviderSyncProfile' do
    association :provider, factory: [:user, :clinical]
  end
end
