class PrimaryGuardianApproveInvitationJob < Struct.new(:primary_guardian_id, :secondary_guardian_id)
  def self.send(primary_guardian_id, secondary_guardian_id)
    Delayed::Job.enqueue new(primary_guardian_id, secondary_guardian_id)
  end

  def perform
    primary_guardian = User.find_by(id: primary_guardian_id)
    secondary_guardian = User.find_by(id: secondary_guardian_id)
    UserMailer.primary_guardian_approve_invitation(primary_guardian, secondary_guardian).deliver if primary_guardian && secondary_guardian
  end

  def queue_name
    'registration_email'
  end
end
