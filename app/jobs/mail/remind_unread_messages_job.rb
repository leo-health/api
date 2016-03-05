class RemindUnreadMessagesJob < Struct.new(:user_id, :staff_message_id)
  RESPOND_WINDOW = 1.hour

  def self.send(user_id, staff_message_id)
    Delayed::Job.enqueue new(user_id, staff_message_id), run_at: Time.now + RESPOND_WINDOW
  end

  def perform
    user = User.find_by_id(user_id)
    staff_message = Message.find_by_id(staff_message_id)
    if user && staff_message
      if staff_message.conversation.open? && guardian_not_response?(staff_message, user)
        UserMailer.remind_unread_messages(user, staff_message).deliver
      end
    end
  end

  def queue_name
    'notification_email'
  end

  private

  def guardian_not_response?(staff_message, guardian)
    Message.where(created_at: staff_message.created_at..staff_message.created_at + RESPOND_WINDOW, sender: guardian).length < 1
  end
end
