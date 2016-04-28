FactoryGirl.define do
  factory :slot, :class => 'Slot' do
    athena_id 1
    start_datetime Time.new(2015,1,1,17)
    end_datetime Time.new(2015,1,1,17,10)
    free_busy_type :free
    association :provider_sync_profile, factory: :provider_sync_profile
  end
end
