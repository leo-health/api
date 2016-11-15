class NotifyCompletedSurveyJob < Struct.new(:provider_id)
  def self.send(provider_id)
    Delayed::Job.enqueue(new(provider_id))
  end

  def perform
    provider = User.find_by_id(provider_id)
    UserMailer.notify_completed_survey(provider).deliver if provider
  end

  def queue_name
    'notification_email'
  end
end
