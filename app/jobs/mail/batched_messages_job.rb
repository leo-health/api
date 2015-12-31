class BatchedMessagesJob < Struct.new(:user_id, :body)
  def self.send(user_id, body)
    Delayed::Job.enqueue(new(user_id, body))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.batched_messages(user, body).deliver if user
  end
end
