class UnaddressedConversationDigestJob < Struct.new(:user_id, :count)
  def self.send(user_id, count)
    Delayed::Job.enqueue(new(user_id, count))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.unaddressed_conversations_digest(user, count).deliver if user
  end

  def queue_name
    'notification_email'
  end
end
