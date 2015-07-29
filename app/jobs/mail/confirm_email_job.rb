class ResetPasswordJob < Struct.new(:user_id, :token)
  def perform
    user = User.try(:find, user_id)
    UserMailer.confirm_password(user, token).deliver if user
  end
end
