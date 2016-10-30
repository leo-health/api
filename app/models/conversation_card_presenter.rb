class ConversationCardPresenter
  include ActionView::Helpers::DateHelper

  def initialize(conversation:, card_id:)
    @color = "#01C0E4"

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

    last_message = @conversation.messages.order(:created_at).last

    last_message_author_name = last_message.sender.try(:full_name)
    last_message_body = last_message.body
    practice_phone = @conversation.family.primary_guardian.practice.phone
    time_ago = time_ago_in_words(last_message.created_at)

    # TODO: think about how to sent templates back and forth. This calculation should be done dynamically on the front end
    date_format = "Sent #{time_ago} ago"

    {
      card_state_type: "CONVERSATION",
      title: "Chat with us",
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
            phone_number: practice_phone
          }
        }
      ]
    }
  end
end
