class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts
  belongs_to :escalated_to, class_name: 'User'
  belongs_to :escalated_by, class_name: 'User'
  belongs_to :sender, class_name: "User"

  validates :conversation, :sender, :message_type, presence: true

  after_commit :update_conversation_after_message_sent, on: :create
  after_commit :update_escalated_status_on_conversation, on: :update

  def read_by!(user)
    r = self.read_receipts.new(participant: user)
    r.save
  end

  def escalate(escalated_to, escalated_by)
    transaction do
      conversation = Conversation.find(conversation_id)
      raise("can't escalate closed message and conversation") if conversation.status == :closed
      conversation.staff << escalated_to unless conversation.staff.where(id: escalated_to.id).exists?
      update_attributes!(escalated_to: escalated_to, escalated_by: escalated_by, escalated_at: Time.now)
      conversation.update_attributes!(status: :escalated)
    end
  end

  private

  def update_conversation_after_message_sent
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
