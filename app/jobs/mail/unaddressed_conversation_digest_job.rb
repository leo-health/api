class UnaddressedConversationDigestJob < Struct.new(:user_id, :count, :state)
  def self.send(user_id, count, state)
    Delayed::Job.enqueue(new(user_id, count, state))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.unaddressed_conversations_digest(user, count, state).deliver if user
  end
end
