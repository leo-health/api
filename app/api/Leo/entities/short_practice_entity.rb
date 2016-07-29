module Leo
  module Entities
    class ShortPracticeEntity < Grape::Entity
      expose :id
      expose :name
      expose :is_open
      expose :available
      expose :oncall_providers

      private

      def oncall_providers
        object.oncall_providers
      end

      def available
        object.available?
      end

      def is_open
        object.in_office_hour?
      end
    end
  end
end
