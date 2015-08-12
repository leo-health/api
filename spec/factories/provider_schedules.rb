FactoryGirl.define do
  factory :provider_schedule do
    athena_provider_id 1
    description "test schedule"
    active true
    monday_start_time "9:00"
    monday_end_time "17:00"
    tuesday_start_time "9:00"
    tuesday_end_time "17:00"
    wednesday_start_time "9:00"
    wednesday_end_time "17:00"
    thursday_start_time "9:00"
    thursday_end_time "17:00"
    friday_start_time "9:00"
    friday_end_time "17:00"
    saturday_start_time "00:00"
    saturday_end_time "00:00"
    sunday_start_time "00:00"
    sunday_end_time "00:00"
  end
end
