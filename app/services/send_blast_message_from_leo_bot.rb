class SendBlastMessageFromLeoBot
  def send_and_notify_message_to_all_families(body)
    send_and_notify_message_to_families(families: Family.all, body: body)
  end

  def send_and_notify_message_to_families(families:, body:)
    broadcast_messages(send_message_to_families(families: families, body: body))
  end

  def send_message_to_families(families:, body:)
    Message.transaction do
      families.map do |f|
        f.conversation.messages.create!(
          sender: User.leo_bot,
          type_name: :text,
          body: body
        )
      end
    end
  end

  def broadcast_messages(messages)
    messages.each(&:broadcast_message)
  end
end
