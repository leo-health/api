module Leo
  module Entities
    class PracticeEntity < Grape::Entity
      expose :id
      expose :name
      expose :address_line_1
      expose :address_line_2
      expose :city
      expose :state
      expose :zip
      expose :fax
      expose :phone
      expose :email
      expose :time_zone
      expose :staff, with: Leo::Entities::UserEntity
      expose :active_schedules, with: Leo::Entities::PracticeScheduleEntity
      expose :schedule_exceptions, with: Leo::Entities::ProviderLeaveEntity

      private

      def time_zone
        #This request should be based on the device requesting the data
        ActiveSupport::TimeZone.find_tzinfo(object.time_zone).name
      end

      def active_schedules
        object.practice_schedules.where(active: true).first
      end

      def schedule_exceptions
        ProviderLeave.where(description: "Seeded holiday").select("start_datetime, end_datetime").uniq(:start_datetime)
      end
    end
  end
end
