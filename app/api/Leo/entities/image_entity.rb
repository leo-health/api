module Leo
  module Entities
    class ImageEntity < Grape::Entity
      expose :base_url
      expose :parameters
      expose :full_size_image_url
      expose :web_app_image_url

      private

      def full_size_image_url
        object.url
      end

      def web_app_image_url
        object.primary_2x.url
      end

      def get_uri
        image_version = DEVICE_IMAGE_SIZE_MAP[options[:device_type]] || :primary_3x
        URI(object.send(image_version).url) if object.respond_to?(image_version)
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
