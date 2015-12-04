class SmsNotification
  def initialize(from, to, cool_down_period=nil)
    @from = from
    @to = to
    @cool_down_period = cool_down_period
  end

  def ready_to_sms?
    next_sending_time = $redis.get("#{to.id}next_messageAt")
    !next_sending_time || (Time.now < next_sending_time)
  end

  def send(body)
    TWILIO.account.messages.create(from: from, to: to, body: body)
  end

  def set_next_send_at
    return unless cool_down_period
    $redis.set("#{to.id}next_messageAt", Time.now + cool_down_period)
  end

  private

  attr_reader :from, :to, :cool_down_period
end
