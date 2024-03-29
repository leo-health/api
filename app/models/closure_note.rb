class ClosureNote < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :closure_reason
  belongs_to :closed_by, ->{ staff }, class_name: 'User'

  validates :conversation, :closed_by, :closure_reason_id, presence: true
  after_commit :broadcast_closure_note, on: :create

  private

  def broadcast_closure_note
    note_params = { message_type: :close,
                    sender_id: closed_by.id,
                    id: id }
    begin
      Pusher.trigger("private-conversation#{conversation.id}", :new_message, note_params)
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
