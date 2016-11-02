module Leo
  module Entities
    class LinkPreviewEntity < Grape::Entity
      expose :title
      expose :body
      expose :icon
      expose :deep_link
      expose :tint_color_hex
      expose :tinted_header_text
      expose :dismiss_button_text
      expose :deep_link_button_text
      expose :category

      def deep_link
        object.full_deep_link_with_scheme
      end

      private

      def icon
        # icon will never be nil
        # https://github.com/carrierwaveuploader/carrierwave
        # Note: u.avatar will never return nil, even if there is no photo associated to it.
        if object.icon.url
          Leo::Entities::ImageEntity.represent(object.icon, options)
        end
      end
    end
  end
end
