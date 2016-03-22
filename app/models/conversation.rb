class Conversation < ActiveRecord::Base
  include AASM
  acts_as_paranoid

  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", through: :user_conversations
  has_many :closure_notes
  has_many :escalation_notes
  belongs_to :family

  validates :family, :state, presence: true
  after_commit :load_initial_message, :broadcast_conversation_by_state, on: :create

  aasm whiny_transitions: false, column: :state do
    state :closed, initial: true
    state :escalated
    state :open

    event :escalate do
      after do
        broadcast_conversation_by_state
      end

      transitions from: [:open, :escalated], to: :escalated, guard: :escalate_conversation_to_staff
    end

    event :close do
      after do
        broadcast_conversation_by_state
      end

      transitions from: [:open, :escalated], to: :closed, guard: :close_conversation
    end

    event :open do
      after do
        broadcast_conversation_by_state
      end

      transitions from: :closed, to: :open
    end
  end

  def escalate_conversation_to_staff(escalation_params) # NOTE: escalation_params = {escalated_to: staff, note: 'note', priority: 1, escalated_by: staff}
    ActiveRecord::Base.transaction do
      @escalation_note = escalation_notes.create!(escalation_params)
    end
  rescue
    false
  end

  def close_conversation(close_params) # NOTE: close_params = {closed_by: staff, note: 'note'}
    ActiveRecord::Base.transaction do
      @closure_note = closure_notes.create!(close_params)
    end
  rescue
    false
  end

  def last_closed_at
    last_closure_note.try(:created_at)
  end

  def last_closure_note
    closure_notes.order('created_at DESC').first
  end

  def last_escalation_note
    escalation_notes.order('created_at DESC').first
  end

  private

  MESSAGE_BODY = "Welcome! My name is Catherine and I run the office here at Flatiron Pediatrics. If you ever need to reach us with questions, concerns or requests, feel free to use this messaging channel and we'll get back to you right away."

  def load_initial_message
    if sender = User.find_by_email('catherine@flatironpediatrics.com')
       messages.create( body: MESSAGE_BODY,
                        sender: sender,
                        type_name: :text
                       )
    end
  end

  def broadcast_conversation_by_state
    begin
      Pusher.trigger("private-newConversation", :new_conversation, { id: id, conversation_state: state })
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
