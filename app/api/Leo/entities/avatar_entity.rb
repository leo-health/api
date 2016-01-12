module Leo
  module Entities
    class AvatarEntity < Grape::Entity
      expose :id
      expose :avatar
      expose :owner_type
      expose :owner_id
      expose :created_at, as: :created_datetime

      private

      def avatar
        uri = URI(object.avatar.url) if object.avatar
        Rack::Utils.parse_query(uri.query).merge(base_url:"#{uri.scheme}://#{uri.host}")
      end
    end
  end
end
