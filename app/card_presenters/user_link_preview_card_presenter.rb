class UserLinkPreviewCardPresenter
  def initialize(user_link_preview:, card_id:)
    @user_link_preview = user_link_preview
    @card_id = card_id
    @color = user_link_preview.link_preview.tint_color_hex
    image = user_link_preview.link_preview.try(:icon)
    @icon = image.try(:url) ? Leo::Entities::ImageEntity.represent(image) : nil
  end

  def present
    card_id = @card_id
    current_state = present_state

    {
      card_id: card_id,
      card_type: "survey",
      current_state: current_state,
      states: [
        current_state
      ]
    }
  end

  def present_state
    card_id = @card_id
    color = @color
    icon = @icon
    user_link_preview_id = @user_link_preview.id
    link_preview = @user_link_preview.link_preview

    {
      card_state_type: "LINK_PREVIEW",
      title: link_preview.title,
      icon: icon,
      color: color,
      tinted_header: link_preview.tinted_header_text,
      body: link_preview.body,
      footer: "",
      button_actions: [
        {
          display_name: link_preview.deep_link_button_text,
          action_type: "OPEN_URL",
          payload: {
            url: link_preview.full_deep_link_with_scheme
          }
        },
        {
          display_name: link_preview.dismiss_button_text,
          action_type: "DISMISS_CONTENT_CARD",
          payload: {
            card_id: card_id,
            user_link_preview_id: user_link_preview_id
          }
        }
      ]
    }
  end
end
