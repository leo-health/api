class EscalationNote < ActiveRecord::Base
  belongs_to :escalated_to, ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :escalated_by, ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :conversation

  validates :conversation, :escalated_by, :escalated_to, :priority, presence: true

  after_commit :notify_escalatee, on: :create

  def active?
    created_at > conversation.last_closed_at
  end

  private

  def notify_escalatee
    NotifyEscalatedConversationJob.send(escalated_to.id)
  end

  def broadcast_escalation_note
    note_params = { message_type: :escalation,
                    created_by: escalated_by,
                    escalated_to: escalated_to,
                    id: id }
    begin
      Pusher.trigger("private-conversation#{conversation.id}", 'new_state', note_params)
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
