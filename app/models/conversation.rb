class Conversation < ActiveRecord::Base
  acts_as_paranoid
  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  before_validation :set_conversation_state, on: :create

  validates :family, :status, presence: true
  around_update :track_conversation_change
  after_commit :load_staff, :load_initial_message, on: :create


  def set_conversation_state
    update_attributes(status: :open) unless status
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
                        message_type: :text
                       )
    end
  end
end
