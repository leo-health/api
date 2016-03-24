class SyncServiceErrorJob < Struct.new(:subject, :message)
  def self.send(subject, message)
    Delayed::Job.enqueue(new(subject, message))
  end

  def perform
    SyncServiceMailer.error(subject, message).deliver
  end

  def queue_name
    'notification_email'
  end
end
