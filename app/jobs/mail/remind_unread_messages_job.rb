class RemindUnreadMessagesJob < Struct.new(:user_id, :staff_message_id)
  RESPOND_WINDOW = 1.hour

  def self.send(user_id, staff_message_id)
    Delayed::Job.enqueue new(user_id, staff_message_id), run_at: Time.now + RESPOND_WINDOW
  end

  def perform
    user = User.find_by_id(user_id)
    staff_message = Message.find_by_id(staff_message_id)
    if user && staff_message
      unless Message.where(created_at: staff_message.created_at..staff_message.created_at + RESPOND_WINDOW, sender: user).length > 0
        UserMailer.remind_unread_messages(user, staff_message).deliver
      end
    end
  end
end
