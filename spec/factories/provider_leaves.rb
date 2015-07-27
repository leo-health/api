FactoryGirl.define do
  factory :provider_leave, :class => 'ProviderLeave' do
    athena_provider_id 1
    description "test leave"
    date Date.today
    start_time "9:00"
    end_time "12:00"
  end

end
