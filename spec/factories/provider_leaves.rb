FactoryGirl.define do
  factory :provider_leave, :class => 'ProviderLeave' do
    athena_provider_id 1
    description "test leave"
    start_datetime "2015-01-01 17:00"
    end_datetime "2015-01-01 20:00"
  end

end
