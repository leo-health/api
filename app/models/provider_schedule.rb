class ProviderSchedule < ActiveRecord::Base
  include Schedule
  validates_presence_of :athena_provider_id, :monday_start_time, :monday_end_time, :tuesday_start_time,
                        :tuesday_end_time, :wednesday_start_time, :wednesday_end_time, :thursday_start_time,
                        :thursday_end_time, :friday_start_time, :friday_end_time, :saturday_start_time,
                        :saturday_end_time, :sunday_start_time, :sunday_end_time

  def self.create_default_with_provider!(provider)
    ProviderSchedule.create!({
      athena_provider_id: provider.athena_id,
      description: "Default Schedule",
      active: true,
      monday_start_time: "08:00",
      monday_end_time: "11:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "19:20",
      thursday_start_time: "08:00",
      thursday_end_time: "13:00",
      friday_start_time: "09:00",
      friday_end_time: "18:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    })
  end
end
