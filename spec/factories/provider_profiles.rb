FactoryGirl.define do
  factory :provider_profile, :class => 'ProviderProfile' do
    association :provider, factory: [:user, :clinical]
    credentials ["M.D.", "M.B.A"]
    specialties [ "pediatrics", "obesity"]
  end
end
