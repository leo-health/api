class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts
  belongs_to :sender, class_name: "User"

  validates :conversation, :sender, :type_name, :body, presence: true
  after_commit :update_conversation_after_message_sent, :set_last_message_created_at, on: :create

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
end
