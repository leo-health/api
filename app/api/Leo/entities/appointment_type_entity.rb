module Leo
  module Entities
    class AppointmentTypeEntity < Grape::Entity
      expose :id
      expose :type_id
      expose :type
      expose :name
      expose :duration
      expose :short_description
      expose :long_description

      private
      def type_id
        object.id
      end

      def type
        object.name.split(' ').first
      end
    end
  end
end
