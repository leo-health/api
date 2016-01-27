class RemindUnreadMessagesJob < Struct.new(:user_id, :body, run_at)
  RESPOND_WINDOW = 1.hour

  def self.send(user_id)
    Delayed::Job.enqueue new(user_id), run_at: Time.now + RESPOND_WINDOW
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.batched_messages(user, body).deliver if user
  end
end
