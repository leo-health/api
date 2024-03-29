class PasswordChangeConfirmationJob < Struct.new(:user_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.password_change_confirmation(user).deliver if user
  end

  def queue_name
    'registration_email'
  end
end
