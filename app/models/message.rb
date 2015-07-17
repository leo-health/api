class Message < ActiveRecord::Base
  belongs_to :conversation
  has_many :read_receipts
  belongs_to :escalated_to, class_name: 'User'
  belongs_to :escalated_by, class_name: 'User'

  after_save :update_conversation_last_message_timestamp, on: [:create]

  def read_by!(user)
    r = self.read_receipts.new(participant: user)
    r.save
  end

  def resolved
    !self.resolved_approved_at.nil?
  end

  private

  def update_conversation_last_message_timestamp
    conversation = self.conversation
    conversation.update_attribute(:last_message_created, self.created_at)
  end

end
