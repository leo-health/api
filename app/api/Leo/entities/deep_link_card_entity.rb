module Leo
  module Entities
    class DeepLinkCardEntity < Grape::Entity
      expose :title
      expose :body
      expose :icon_url
      expose :deep_link
      expose :tint_color_hex
      expose :tinted_header_text
      expose :dismiss_button_text
      expose :deep_link_button_text

      def deep_link
        "#{ENV['DEEPLINK_SCHEME']}://#{object.deep_link}"
      end
    end
  end
end
