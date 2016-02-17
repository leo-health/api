class PrimaryGuardianApproveInvitationJob < Struct.new(:primary_guardian_id, :enrollment_auth_token)
  def self.send(primary_guardian_id, enrollment_auth_token)
    Delayed::Job.enqueue(new(primary_guardian_id, enrollment_auth_token))
  end

  def perform
    user = User.find_by_id(primary_guardian_id)
    UserMailer.primary_guardian_approve_invitation(user, enrollment_auth_token).deliver if user
  end
end
