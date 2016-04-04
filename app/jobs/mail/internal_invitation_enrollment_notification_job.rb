class InternalInvitationEnrollmentNotificationJob < Struct.new(:secondary_guardian_id)
  def self.send(secondary_guardian_id)
    Delayed::Job.enqueue(new(secondary_guardian_id))
  end

  def perform
    user = User.find_by(id: secondary_guardian_id)
    UserMailer.internal_invitation_enrollment_notification(user).deliver if user
  end

  def queue_name
    'notification_email'
  end
end
