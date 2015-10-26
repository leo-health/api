class Conversation < ActiveRecord::Base
  include AASM
  acts_as_paranoid

  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  has_many :closure_notes
  belongs_to :family

  validates :family, :state, presence: true

  after_commit :load_staff, :load_initial_message, on: :create

  def self.sort_conversations
    %i(open escalated closed).inject([]) do |conversations, state|
      conversations << self.where(state: state).order('updated_at desc')
      conversations.flatten
    end
  end

  #state machine via https://github.com/aasm/aasm
  aasm :whiny_transitions => false, :column => :state do
    state :closed, :initial => true
    state :escalated
    state :open

    event :escalate do
      after do |args|
        broadcast_state(:escalation, args[:escalated_by], @escalation_note.id, args[:escalated_to])
      end

      transitions :from => [:open, :escalated], :to => :escalated, :guard => :escalate_conversation_to_staff
    end

    event :close do
      after do |args|
        broadcast_state(:close, args[:closed_by], @closure_note.id)
      end

      transitions :from => [:open, :escalated], :to => :closed, :guard => :close_conversation
    end

    event :open do
      after do |args|
        broadcast_state(:open, false, false)
      end

      transitions :from => :closed, :to => :open
    end
  end

  def escalate_conversation_to_staff(escalation_params)
    # NOTE: escalation_params = {escalated_to: staff, note: 'note', priority: 1, escalated_by: staff}
    ActiveRecord::Base.transaction do
      user_conversation = user_conversations.create_with(escalated: true).find_or_create_by!(staff: escalation_params[:escalated_to])
      escalation_note_params = escalation_params.except(:escalated_to)
      @escalation_note = user_conversation.escalation_notes.create!(escalation_note_params)
      true
    end
  rescue
    false
  end

  def close_conversation(close_params)
    # NOTE: close_params = {closed_by: staff, note: 'note'}
    ActiveRecord::Base.transaction do
      user_conversations.each{|i| i.update_attributes!(escalated: false)}
      @closure_note = closure_notes.create!(conversation: self, note: close_params[:note], closed_by: close_params[:closed_by])
      true
    end
  rescue
    false
  end

  def broadcast_state(message_type, changed_by, note_id, changed_to = nil)
    channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newState#{user.email}"; channels}
    Pusher.trigger(channels, 'new_state', {message_type: message_type, conversation_id: id, created_by: changed_by, escalated_to: changed_to, id: note_id}) if channels.count > 0
  end

  private

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
