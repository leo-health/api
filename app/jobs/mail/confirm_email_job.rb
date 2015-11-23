class ConfirmEmailJob < Struct.new(:user_id, :token)
  def perform
    user = User.find_by_id(user_id)
    UserMailer.confirmation_instructions(user, token).deliver if user
  end

  def send
    Delayed::Job.enqueue self
  end
end
