module Leo
  module Entities
    class PracticeScheduleEntity < Grape::Entity
      expose :schedule_type
      expose :daily_hours

      private
      def daily_hours
        [
          { id: 1, start_time: object.monday_start_time, end_time: object.monday_end_time, day_of_the_week: "monday" },
          { id: 2, start_time: object.tuesday_start_time, end_time: object.tuesday_end_time, day_of_the_week: "tuesday" },
          { id: 3, start_time: object.wednesday_start_time, end_time: object.wednesday_end_time, day_of_the_week: "wednesday" },
          { id: 4, start_time: object.thursday_start_time, end_time: object.thursday_end_time, day_of_the_week: "thursday" },
          { id: 5, start_time: object.friday_start_time, end_time: object.friday_end_time, day_of_the_week: "friday" },
          { id: 6, start_time: object.saturday_start_time, end_time: "23:59", day_of_the_week: "saturday" },
          { id: 7, start_time: object.sunday_start_time, end_time: "23:59", day_of_the_week: "sunday" }
        ]
      end
    end
  end
end
