class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts
  belongs_to :sender, class_name: "User"

  validates :conversation, :sender, :type_name, presence: true

  after_commit :update_conversation_after_message_sent, on: :create
  after_commit :update_escalated_status_on_conversation, on: :update

  def broadcast_message(sender)
    message_id = id
    conversation = self.conversation
    participants = (conversation.staff + conversation.family.guardians)
    participants.delete(sender)
    if participants.count > 0
      channels = participants.inject([]){|channels, user| channels << "newMessage#{user.email}"; channels}
      Pusher.trigger(channels, 'new_message', message_id)
    end
  end

  private

  def update_conversation_after_message_sent
    return if conversation.messages.count == 1
    conversation.staff << sender unless conversation.staff.where(id: sender.id).exists?
    conversation.user_conversations.update_all(read: false)
    unless conversation.status == :escalated
      conversation.update_column(:status, :open)
      conversation.update_column(:last_message_created_at, created_at)
    end
    conversation.user_conversations.update_all(read: false)
  end


  def update_escalated_status_on_conversation
    UserConversation.find_by_conversation_id_and_user_id(conversation.id, escalated_to_id)
        .try(:update_attributes, {escalated: true})
  end
end
