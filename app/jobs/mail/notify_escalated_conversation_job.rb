class NotifyEscalatedConversationJob < Struct.new(:user_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.notify_escalated_conversation(user).deliver if user
  end

  def queue_name
    'notification_email'
  end
end
