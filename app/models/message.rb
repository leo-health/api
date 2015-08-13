class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts
  belongs_to :escalated_to, class_name: 'User'
  belongs_to :escalated_by, class_name: 'User'
  belongs_to :sender, class_name: "User"

  validates :conversation, :sender, :message_type, presence: true

  after_commit :update_conversation_last_message_timestamp, :update_read_status_on_conversation, on: :create
  after_commit :update_escalated_status_on_conversation, on: :update

  def read_by!(user)
    r = self.read_receipts.new(participant: user)
    r.save
  end

  def escalate(escalated_to, escalated_by)
    Conversation.find(conversation_id).staff << escalated_to
    update_attributes(escalated_to: escalated_to, escalated_by: escalated_by, escalated_at: Time.now)
  end

  private
  def update_escalated_status_on_conversation
    UserConversation.find_by_conversation_id_and_user_id(conversation.id, escalated_to_id)
        .try(:update_attributes, {escalated: true})
  end

  def update_read_status_on_conversation
    conversation.user_conversations.update_all(read: false)
  end

  def update_conversation_last_message_timestamp
    conversation.update_attributes(last_message_created_at: created_at)
  end
end
