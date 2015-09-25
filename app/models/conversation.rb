class Conversation < ActiveRecord::Base
  acts_as_paranoid
  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  has_many :escalation_notes
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  before_validation :set_conversation_state, on: :create

  validates :family, :status, presence: true
  around_update :track_conversation_change
  after_commit :load_staff, :load_initial_message, on: :create

  def self.sort_conversations
    %i(open escalated closed).inject([]) do |conversations, status|
      conversations << self.where(status: status).order('updated_at desc')
      conversations.flatten
    end
  end

  def set_conversation_state
    update_attributes(status: :open) unless status
  end

  def escalate_conversation(escalated_by_id, escalated_to_id, note, priority)
    update_attributes(status: :escalated)
    user_conversation = user_conversations.find_or_create_by(user_id: escalated_to_id, escalated: true)
    if user_conversation.valid?
      escalation_note = user_conversation.escalation_notes.create(note: note, priority: priority, escalated_by_id: escalated_by_id)
    end
    escalation_note
  end

  def close_conversation
    false if status == :closed
    user_conversations.update_all(escalated: false)
    update_attributes(status: :closed, last_closed_at: Time.now, last_closed_by: current_user.id)
  end

  private

  def track_conversation_change
    changed = status_changed?
    yield
    conversation_changes.create(conversation_change: changes.slice(:status, :updated_at)) if changed
  end

  def load_staff
    #neeed definitions for who will be loaded here
  end

  def load_initial_message
    if sender = User.where(role_id: 3).first
       messages.create( body: "Welcome to Leo! If you have any questions or requests, feel free to reach us at any time.",
                        sender: sender,
                        type_name: :text
                       )
    end
  end
end
