class ResetPasswordJob < Struct.new(:user_id, :token)
  def perform
    user = User.find_by_id(user_id)
    UserMailer.reset_password_instructions(user, token).deliver if user
  end

  def send
    Delayed::Job.enqueue self
  end
end
