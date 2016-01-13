require 'twilio-ruby'

class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  has_one :message_photo, inverse_of: :message
  accepts_nested_attributes_for :message_photo

  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts

  validates :conversation, :sender, :type_name, presence: true
  validates :body, presence: true, if: :text_message?
  after_commit :actions_after_message_sent, on: :create

  def text_message?
    type_name == 'text'
  end

  def self.compile_sms_message(start_time, end_time)
    messages = self.includes(:sender).where.not(sender: [User.leo_bot, User.customer_service_user]).where(created_at: (start_time..end_time))
    messages.inject(Hash.new(0)) do |compiled_message, message|
      sender = message.sender
      full_name = "#{sender.full_name} #{sender.id.to_s}"
      compiled_message[full_name] += 1
      compiled_message
    end.map{|name, count| "#{name.split.take(2).join(' ')} sent you #{count} messages."}.join(' ')
  end

  def broadcast_message(sender)
    message_id = id
    conversation = self.conversation
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

  def actions_after_message_sent
    set_last_message_created_at
    return if ( sender.has_role?(:bot) || initial_welcome_message? )
    update_conversation_after_message_sent
    sms_cs_user
    send_new_message_notification
    email_batched_messages
  end

  def initial_welcome_message?
    body == "Welcome to Leo! If you have any questions or requests, feel free to reach us at any time."
  end

  def set_last_message_created_at
    conversation.update_columns(last_message_created_at: created_at, updated_at: created_at)
  end

  def update_conversation_after_message_sent
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
    return if !cs_user || sender == cs_user || $redis.get("#{cs_user.id}online?") == "yes"
    if ready_to_notify?(cs_user)
      body = Message.compile_sms_message(Time.now - 2.minutes, Time.now)
      SendSmsJob.send(cs_user.id, body)
      set_next_send_at(cs_user, 2.minutes)
    end
  end

  def email_batched_messages
    conversation.family.guardians.each do |guardian|
      if ready_to_notify?(guardian) && sender != guardian
        BatchedMessagesJob.send(guardian.id, "You have new messages!")
        set_next_send_at(guardian, 5.minutes)
      end
    end
  end

  def ready_to_notify?(receiver)
    next_sending_time = $redis.get("#{receiver.id}next_messageAt")
    !next_sending_time || (Time.now > Time.parse(next_sending_time))
  end

  def set_next_send_at(receiver, cool_down_period)
    $redis.set("#{receiver.id}next_messageAt", Time.now + cool_down_period)
  end
end
