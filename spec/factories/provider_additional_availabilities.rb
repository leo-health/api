FactoryGirl.define do
  factory :provider_additional_availability do
    athena_provider_id 1
    description "test additional availability"
    date Date.today
    start_time "17:00"
    end_time "20:00"
  end

end
