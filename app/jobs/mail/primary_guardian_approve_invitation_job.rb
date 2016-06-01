class PrimaryGuardianApproveInvitationJob < Struct.new(:primary_guardian, :secondary_guardian)
  def self.send(primary_guardian, secondary_guardian )
    Delayed::Job.enqueue new(primary_guardian, secondary_guardian)
  end

  def perform
    UserMailer.primary_guardian_approve_invitation(primary_guardian, secondary_guardian).deliver if primary_guardian && secondary_guardian
  end

  def queue_name
    'registration_email'
  end
end
