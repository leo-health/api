class ConversationCardPresenter
  include ActionView::Helpers::DateHelper

  def initialize(conversation:, card_id:)
    @color = "#01C0E4"
    @icon = Leo::Entities::ImageEntity.represent(CardIcon.conversation.icon)

    @conversation = conversation
    @card_id = card_id
  end

  def present
    card_id = @card_id
    current_state = present_recent_message

    {
      card_id: card_id,
      card_type: "conversation",
      associated_data: Leo::Entities::ConversationEntity.represent(@conversation),
      current_state: current_state,
      states: [current_state]
    }
  end

  def present_recent_message
    conversation_id = @conversation.id
    color = @color
    icon = @icon

    last_message = @conversation.messages.order(:created_at).last
    last_message_author_name = last_message.sender.try(:full_name)
    last_message_body = last_message.body
    if last_message.type_name.to_sym == :image
      sender_name = last_message.sender.full_name.try(:capitalize)
      last_message_body = "#{sender_name || "Someone"} sent an image."
    end

    practice = @conversation.family.primary_guardian.practice
    practice_phone = practice.phone
    contact_name = practice.name

    time_ago = time_ago_in_words(last_message.created_at)

    # TODO: think about how to sent templates back and forth. This calculation should be done dynamically on the front end
    date_format = "Sent #{time_ago} ago"

    {
      card_state_type: "CONVERSATION",
      title: "Chat with us",
      icon: icon,
      color: color,
      tinted_header: last_message_author_name,
      body: last_message_body,
      footer: date_format, # flag this as a calculated field?
      button_actions: [
        {
          display_name: "MESSAGE US",
          action_type: "OPEN_PRACTICE_CONVERSATION",
          payload: {
            conversation_id: conversation_id
          }
        },
        {
          display_name: "CALL US",
          action_type: "CALL_PHONE",
          payload: {
            phone_number: practice_phone,
            contact_name: contact_name
          }
        }
      ]
    }
  end
end
