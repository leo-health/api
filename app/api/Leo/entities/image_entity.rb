module Leo
  module Entities
    class ImageEntity < Grape::Entity
      expose :base_url
      expose :parameters

      private

      def get_uri
        URI(object.url)
      end

      def base_url
        uri = get_uri
        "#{uri.scheme}://#{uri.host}"
      end

      def parameters
        uri = get_uri
        Rack::Utils.parse_query(uri.query)
      end
    end
  end
end