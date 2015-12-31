class WelcomeToPracticeJob < Struct.new(:user_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.welcome_to_pratice(user).deliver if user
  end
end
