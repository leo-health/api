class ProviderSchedule < ActiveRecord::Base
  validates_presence_of :athena_provider_id, :monday_start_time, :monday_end_time, :tuesday_start_time,
                        :tuesday_end_time, :wednesday_start_time, :wednesday_end_time, :thursday_start_time,
                        :thursday_end_time, :friday_start_time, :friday_end_time, :saturday_start_time,
                        :saturday_end_time, :sunday_start_time, :sunday_end_time
end
