FactoryGirl.define do
  factory :provider_profy, :class => 'ProviderProfie' do
    association :provider, factory: [:user, :clinical]
    credentials ["M.D.", "M.B.A"]
    specialties [ "pediatrics", "obesity"]
  end
end
