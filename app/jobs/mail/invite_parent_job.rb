class InviteParentJob < Struct.new(:user_to_invite_id, :inviting_user_id)
  def self.send(user_to_invite_id, inviting_user_id)
    Delayed::Job.enqueue(new(user_to_invite_id, inviting_user_id))
  end

  def perform
    user_to_invite = User.find_by(id: user_to_invite_id)
    inviting_user = User.find_by(id: inviting_user_id)
    UserMailer.invite_secondary_parent(user_to_invite, inviting_user).deliver if user_to_invite && inviting_user
  end

  def queue_name
    'registration_email'
  end
end
