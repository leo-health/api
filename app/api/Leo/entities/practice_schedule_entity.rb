module Leo
  module Entities
    class PracticeScheduleEntity < Grape::Entity
		expose :schedule_type
		expose :monday
		expose :tuesday
		expose :wednesday
		expose :thursday
		expose :friday
		expose :saturday
		expose :sunday

		private
		#suboptimal
		def monday
			{ id: 1, start_time: object.monday_start_time, end_time: object.monday_end_time }
		end

		def tuesday
			{ id: 2, start_time: object.tuesday_start_time, end_time: object.tuesday_end_time }
		end

		def wednesday
			{ id: 3, start_time: object.wednesday_start_time, end_time: object.wednesday_end_time }
		end

		def thursday
			{ id: 4, start_time: object.thursday_start_time, end_time: object.thursday_end_time }
		end

		def friday
			{ id: 5, start_time: object.friday_start_time, end_time: object.friday_end_time }
		end

		def saturday
			{ id: 6, start_time: object.saturday_start_time, end_time: "23:59" }
		end

		def sunday
			{ id: 7, start_time: object.sunday_start_time, end_time: "23:59" }
		end
    end
  end
end
