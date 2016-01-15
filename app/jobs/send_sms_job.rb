class SendSmsJob < Struct.new(:receiver_id, :sender_id, :type, :run_at)

  COOL_DOWN_PERIOD = 2.minutes

  def self.send(receiver_id, type, run_at, sender_id)
    byebug
    @run_at = Time.parse(run_at)
    Delayed::Job.enqueue new(receiver_id, type, sender_id), run_at: @run_at
  end

  def perform
    byebug
    receiver = User.find_by_id(receiver_id)
    body = message_body(sender_id)

    sms_user(receiver.phone, body) if receiver
    set_next_cool_down_period(receiver_id, COOL_DOWN_PERIOD)
    unpause_schedule_sms_jobs(receiver_id)
  end

  private

  def message_body(sender_id)
    if type == :batched
      Message.compile_sms_message(@run_at - COOL_DOWN_PERIOD, @run_at)
    elsif type == :single
      byebug
      return unless sender = User.find_by_id(sender_id)
      "#{sender.full_name} sent you 1 message!"
    end
  end

  def sms_user(phone, body)
    TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
  end

  def unpause_schedule_sms_jobs(receiver_id)
    $redis.set("#{receiver_id}batch_scheduled?", false)
  end

  def set_next_cool_down_period(receiver_id, cool_down_period)
    $redis.set("#{receiver_id}next_messageAt", Time.now + cool_down_period)
  end
end
