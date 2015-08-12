class Message < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :conversation
  has_many :read_receipts
  has_many :readers, class_name: 'User', through: :read_receipts
  belongs_to :escalated_to, class_name: 'User'
  belongs_to :escalated_by, class_name: 'User'
  belongs_to :sender, class_name: "User"

  after_commit :update_conversation_last_message_timestamp, on: :create

  validates :conversation, :sender, :message_type, presence: true

  def read_by!(user)
    r = self.read_receipts.new(participant: user)
    r.save
  end

  def escalate(escalated_to, escalated_by)
    update_attributes(escalated_to: escalated_to, escalated_by: escalated_by, escalated_at: Time.now)
  end

  private

  def update_conversation_last_message_timestamp
    conversation.update_attributes(last_message_created_at: created_at)
  end
end
