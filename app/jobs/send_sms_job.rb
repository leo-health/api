class SendSmsJob < Struct.new(:receiver_id, :sender_id, :sms_type, :run_at)

  COOL_DOWN_PERIOD = 2.minutes

  def self.send(receiver_id, sender_id, sms_type, run_at)
    @run_at = Time.parse(run_at)
    Delayed::Job.enqueue new(receiver_id, sender_id, sms_type, run_at), run_at: @run_at
  end

  def perform
    receiver = User.find_by_id(receiver_id)
    body = message_body(sender_id, run_at)
    sms_user(receiver.phone, body) if receiver
    return if sms_type == :escalation
    set_next_cool_down_period(receiver_id, COOL_DOWN_PERIOD)
    unpause_schedule_sms_jobs(receiver_id)
  end

  private

  def message_body(sender_id, run_at)
    if sms_type == :batched
      end_time = Time.parse(run_at)
      Message.compile_sms_message(end_time - COOL_DOWN_PERIOD, end_time)
    elsif sms_type == :single
      return unless sender = User.find_by_id(sender_id)
      "#{sender.full_name} sent you 1 message!"
    elsif sms_type == :escalation
      "A conversation has been escalated to you by #{sender.full_name}!"
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
