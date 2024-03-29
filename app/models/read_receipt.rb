class ReadReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :reader, class_name: 'User'

  validates :message, :reader, presence: true
  validates_uniqueness_of :reader_id, scope: :message_id

  after_commit :update_conversation_read_status, on: :create

  private

  def update_conversation_read_status
    if user_conversation = UserConversation.find_by_conversation_id_and_user_id(message.conversation_id, reader.id)
      user_conversation.update_column(:read, true)
    end
  end
end
