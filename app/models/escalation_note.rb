class EscalationNote < ActiveRecord::Base
  belongs_to :escalated_to, ->{ staff }, class_name: 'User'
  belongs_to :escalated_by, ->{ staff }, class_name: 'User'
  belongs_to :conversation

  validates :conversation, :escalated_by, :escalated_to, :priority, presence: true

  after_commit :notify_escalatee, :broadcast_escalation_note, on: :create

  def active?
    return true unless conversation.last_closed_at
    created_at > conversation.last_closed_at
  end

  private

  def notify_escalatee
    NotifyEscalatedConversationJob.send(escalated_to.id)
  end

  def broadcast_escalation_note
    note_params = { message_type: :escalation,
                    sender_id: escalated_by.id,
                    id: id }
    begin
      Pusher.trigger("private-conversation#{conversation.id}", :new_message, note_params)
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
