class SendSmsJob < Struct.new(:receiver_id, :type, :run_at)
  def self.send(receiver_id, type, run_at)

    Delayed::Job.enqueue new(receiver_id, body, type), run_at: run_at
  end

  def perform
    receiver = User.find_by_id(receiver_id)
    type == :batched ? compile_sms_message("start", "end") : "#{sender.full_name} sent you 1 message!"
    sms_user(receiver.phone, body) if receiver
  end

  private

  def compile_sms_message(start_time, end_time)
    messages = Conversation.includes(:sender).where.not(sender: [User.leo_bot, User.customer_service_user]).where(created_at: (start_time..end_time))
    messages.inject(Hash.new(0)) do |compiled_message, message|
      sender = message.sender
      full_name = "#{sender.full_name} #{sender.id.to_s}"
      compiled_message[full_name] += 1
      compiled_message
    end.map{|name, count| "#{name.split.take(2).join(' ')} sent you #{count} messages."}.join(' ')
  end

  def sms_user(phone, body)
    TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
  end
end
