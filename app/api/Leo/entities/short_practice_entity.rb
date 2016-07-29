module Leo
  module Entities
    class ShortPracticeEntity < Grape::Entity
      expose :id
      expose :name
      expose :available
      expose :oncall_providers, with: Leo::Entities::UserEntity

      private

      def available
        object.available?
      end
    end
  end
end
