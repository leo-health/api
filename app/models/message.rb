require 'twilio-ruby'

class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  has_one :message_photo
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts

  validates :conversation, :sender, :type_name, :body, presence: true
  after_commit :update_conversation_after_message_sent, :set_last_message_created_at, :sms_cs_user, on: :create

  def self.cool_down_period
    2.minutes
  end

  def self.compile_sms_message(start_time, end_time)
    messages = self.includes(:sender).where.not(sender: User.customer_service_user).where(created_at: (start_time..end_time))
    messages.inject(Hash.new(0)) do |compiled_message, message|
      sender_name = "#{message.sender.first_name} #{message.sender.last_name}"
      compiled_message[sender_name] += 1
      compiled_message
    end.map{|name, count| "#{name} sent you #{count} messages."}.join(' ')
  end

  def broadcast_message(sender)
    message_id = id
    conversation = self.conversation
    send_new_message_notification
    participants = (conversation.staff + conversation.family.guardians)
    participants.delete(sender)
    if participants.count > 0
      channels = participants.inject([]){|channels, user| channels << "newMessage#{user.email}"; channels}
      Pusher.trigger(channels, 'new_message', {message_id: message_id, conversation_id: conversation.id})
    end
  end

  def broadcast_message_via_presence_channel
    Pusher.trigger("presence-#{conversation.id}")
  end

  private

  def set_last_message_created_at
    conversation.update_columns(last_message_created_at: created_at, updated_at: created_at)
  end

  def update_conversation_after_message_sent
    return if conversation.messages.count < 2
    conversation.staff << sender unless ( sender.has_role? :guardian ) || ( conversation.staff.where(id: sender.id).exists? )
    conversation.user_conversations.update_all(read: false)
    conversation.open!
  end

  def send_new_message_notification
    apns = ApnsNotification.new
    guardians_to_notify = conversation.family.guardians.includes(:sessions).where.not(id: sender.id)
    guardians_to_notify.each do |guardian|
      apns.delay.notify_new_message(device_token) if device_token = guardian.sessions.last.try(:device_token)
    end
  end

  def sms_cs_user
    cs_user = User.customer_service_user
    return unless $redis.get("#{cs_user.id}online?") == "yes"
    if ready_to_sms?(cs_user)
      body = Message.compile_sms_message(Time.now - Message.cool_down_period, Time.now)
      SendSmsJob.new(cs_user.id, body).send
      set_next_send_at(cs_user)
    end
  end

  def ready_to_sms?(receiver)
    next_sending_time = $redis.get("#{receiver.id}next_messageAt")
    !next_sending_time || (Time.now > Time.parse(next_sending_time))
  end


  def set_next_send_at(receiver)
    $redis.set("#{receiver.id}next_messageAt", Time.now + Message.cool_down_period)
  end
end
