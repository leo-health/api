class InviteParentJob < Struct.new(:enrollment_id, :user_id)
  def perform
    enrollment = Enrollment.try(:find, enrollment_id)
    current_user = User.try(:find, user_id)
    UserMailer.invite_secondary_parent(enrollment, current_user).deliver if ( enrollment && current_user )
  end

  def send
    Delayed::Job.enqueue self
  end
end
