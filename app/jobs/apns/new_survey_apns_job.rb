class NewSurveyApnsJob < Struct.new(:device_token)

  def self.send(device_token)
    Delayed::Job.enqueue new(device_token)
  end

  def perform
    ApnsNotification.new.notify_new_mchat_survey(device_token)
  end

  def queue_name
    'apns_notification'
  end
end
