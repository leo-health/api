module Leo
  module Entities
    class ImageEntity < Grape::Entity
      expose :base_url
      expose :parameters
      expose :url

      private

      def url
        object.url
      end

      def get_uri
        URI(object.url)
      end

      def base_url
        uri = get_uri
        "#{uri.scheme}://#{uri.host}#{uri.path}"
      end

      def parameters
        uri = get_uri
        Rack::Utils.parse_query(uri.query)
      end
    end
  end
end
