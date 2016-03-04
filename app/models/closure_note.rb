class ClosureNote < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :closed_by, ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :conversation, :closed_by, presence: true

  after_commit :broadcast_closure_note, on: :create

  private

  def broadcast_closure_note
    note_params = { message_type: :close,
                    closed_by_id: closed_by.id,
                    id: id }
    begin
      Pusher.trigger("private-conversation#{conversation.id}", 'new_state', note_params)
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
