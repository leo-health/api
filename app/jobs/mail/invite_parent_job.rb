class InviteParentJob < Struct.new(:enrollment_id, :user_id)
  def perform
    enrollment = Enrollment.find_by_id(enrollment_id)
    current_user = User.find_by_id(user_id)
    UserMailer.invite_secondary_parent(enrollment, current_user).deliver if ( enrollment && current_user )
  end

  def send
    Delayed::Job.enqueue self
  end
end
