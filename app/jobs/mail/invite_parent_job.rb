class InviteParentJob < Struct.new(:user_to_invite, :inviting_user)
  def self.send(user_to_invite, inviting_user)
    Delayed::Job.enqueue(new(user_to_invite, inviting_user))
  end

  def perform
    UserMailer.invite_secondary_parent(user_to_invite, inviting_user).deliver if user_to_invite && inviting_user
  end

  def queue_name
    'registration_email'
  end
end
