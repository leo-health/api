class PrimaryGuardianApproveInvitationJob < Struct.new(:primary_guardian_id, :enrollment_id)
  def self.send(primary_guardian_id, enrollment_id )
    Delayed::Job.enqueue(new(primary_guardian_id, enrollment_id))
  end

  def perform
    user = User.find_by_id(primary_guardian_id)
    enrollment = Enrollment.find_by_id(enrolment_id)
    UserMailer.primary_guardian_approve_invitation(user, enrollment).deliver if user && enrollment
  end

  def queue_name
    'registration_email'
  end
end
