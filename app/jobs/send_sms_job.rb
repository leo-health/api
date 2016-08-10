class SendSmsJob < Struct.new(:receiver_id)
  def self.send(receiver_id)
    Delayed::Job.enqueue new(receiver_id)
  end

  def perform
    receiver = User.find_by_id(receiver_id)
    sms_user(receiver.phone, "You have a new message from a Leo Member.") if receiver
  end

  def queue_name
    'sms_notification'
  end

  private

  def sms_user(phone, body)
    unless Rails.env.production?
      TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: '2035223374', body: body)
    else
      TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
    end
  end

  def unpause_schedule_sms_jobs(receiver_id)
    $redis.set("#{receiver_id}batch_scheduled?", false)
  end

  def set_next_cool_down_period(receiver_id, cool_down_period)
    $redis.set("#{receiver_id}next_messageAt", Time.now + cool_down_period)
  end
end
