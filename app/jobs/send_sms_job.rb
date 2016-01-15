class SendSmsJob < Struct.new(:receiver_id, :type, :run_at)
  COOL_DOWN_PERIOD = 2.minutes

  def self.send(receiver_id, type, run_at)
    @run_at = Time.parse(run_at)
    Delayed::Job.enqueue new(receiver_id, type), run_at: run_at
  end

  def perform
    receiver = User.find_by_id(receiver_id)
    type == :batched ? compile_sms_message(@run_at - COOL_DOWN_PERIOD, @run_at) : "#{sender.full_name} sent you 1 message!"
    sms_user(receiver.phone, body) if receiver
    set_next_cool_down_period(cs_user, COOL_DOWN_PERIOD)
    unpause_scedule_sms_jobs(receiver_id)
  end

  private

  def compile_sms_message(start_time, end_time)
    messages = Message.includes(:sender).where.not(sender: [User.leo_bot, User.customer_service_user]).where(created_at: (start_time..end_time))
    messages.inject(Hash.new(0)) do |compiled_message, message|
      sender = message.sender
      compiled_message["#{sender.full_name} #{sender.id.to_s}"] += 1
      compiled_message
    end.map{|name, count| "#{name.split.take(2).join(' ')} sent you #{count} messages."}.join(' ')
  end

  def sms_user(phone, body)
    TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
  end

  def unpause_scedule_sms_jobs(receiver_id)
    $redis.set("#{receiver_id}batch_scheduled?", false)
  end

  def set_next_cool_down_period(receiver, cool_down_period)
    $redis.set("#{receiver.id}next_messageAt", Time.now + cool_down_period)
  end
end
