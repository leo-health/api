class Conversation < ActiveRecord::Base
  acts_as_paranoid

  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  has_many :close_conversation_notes
  belongs_to :last_closed_by, class_name: 'User'
  belongs_to :family

  validates :family, :state, presence: true

  after_commit :load_staff, :load_initial_message, on: :create

  state_machine :state, initial: :closed do
    before_transition on: :escalate do |conversation, trans|
      conversation.escalate_message_to_staff(trans.args.escalated_to)
    end

    after_transition on: :escalate do |conversation, trans|
      escalation_params = trans.args
      conversation.create_escalation_note(escalation_params.note, escalation_params.priority, escalation_params.escalated_by)
    end

    before_transition on: :close do |conversation, trans|
      conversation.user_conversations.update_all(escalated: false)
      conversation.update_attributes(last_closed_at: Time.now, last_closed_by: trans.args.closed_by)
    end

    after_transition on: :close do |conversation, trans|
      close_params = trans.args
      conversation.create_close_note(note, closed_by)
    end

    event :escalate do
      transition [:open, :escalated] => :escalated
    end

    event :close do
      transition [:open, :escalated] => :closed
    end

    state :closed do
      def create_close_note(note, closed_by)
        close_conversation_notes.create(conversation: self, note: note, closed_by: closed_by)
      end
    end

    state :escalated do
      def create_escalation_note(note, priority, escalated_by)
        escalation_note = user_conversation.escalation_notes.create(note: note, priority: priority, escalated_by: escalated_by)
      end
    end

    state :open
  end

  def escalate_message_to_staff(escalated_to)
    return if escalated_to.has_role? :guardian
    user_conversations.create_with(escalated: true).find_or_create_by(user: escalated_to)
  end


  def self.sort_conversations
    %i(open escalated closed).inject([]) do |conversations, state|
      conversations << self.where(state: state).order('updated_at desc')
      conversations.flatten
    end
  end

  def broadcast_state(sender, new_state)
    channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newState#{user.email}"; channels}
    Pusher.trigger(channels, 'new_state', {new_state: new_state, conversation_id: id, changed_by: sender}) if channels.count > 0
  end

  private

  def closed?
    state.to_sym == :closed
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
