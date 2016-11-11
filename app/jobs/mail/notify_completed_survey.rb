class NotifyCompletedSurveyJob < Struct.new(:provider_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id))
  end

  def perform
    provider = User.find_by(id: provider_id)
    UserMailer.notify_completed_survey(provider).deliver if provider
  end

  def queue_name
    'notification_email'
  end
end


# “The {display_name} survey has been completed for {patient_name} and is available under encounter documents in their chart."
