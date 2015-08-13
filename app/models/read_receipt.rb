class ReadReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :reader, class_name: 'User'

  validates :message, :reader, presence: true
  validates_uniqueness_of :reader_id, scope: :message_id

  after_commit :update_conversation_read_status, on: :create

  private

  def update_conversation_read_status
    user_conversation =UserConversation.where(staff_id: reader.id, conversation_id: message.conversation_id)
    user_conversation.try(:update_attributes, {read: true})
  end
end
