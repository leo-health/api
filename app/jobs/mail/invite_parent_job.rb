class InviteParentJob < Struct.new(:enrollment_id)
  def perform
    enrollment = Enrollment.try(:find, enrollment_id)
    UserMailer.invite_secondary_parent(enrollment).deliver if enrollment
  end

  def send
    Delayed::Job.enqueue self
  end
end
