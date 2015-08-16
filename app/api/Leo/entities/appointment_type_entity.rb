module Leo
  module Entities
    class AppointmentTypeEntity < Grape::Entity
      expose :id
      expose :id, as: :type_id
      expose :type
      expose :name
      expose :duration
      expose :short_description
      expose :long_description

      private

      def type
        object.name.split(' ').first
      end
    end
  end
end
