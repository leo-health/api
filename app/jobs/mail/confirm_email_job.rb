class ConfirmEmailJob < Struct.new(:user_id, :token)
  def self.send(user_id, token)
    Delayed::Job.enqueue(new(user_id, token))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.confirmation_instructions(user, token).deliver if user
  end
end
