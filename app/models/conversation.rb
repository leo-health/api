class Conversation < ActiveRecord::Base
  acts_as_paranoid
  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  before_validation :set_conversation_state, on: :create

  validates :family, :state, presence: true
  around_update :track_conversation_change
  after_commit :load_staff, on: :create

  def load_staff
    #define whom are the staff members to be add into a conversation
  end

  def track_conversation_change
    changed = state_changed?
    yield
    conversation_changes.create(conversation_change: changes.slice(:state, :updated_at)) if changed
  end

  def set_conversation_state
    update_attributes(state: "open") unless state
  end
end
