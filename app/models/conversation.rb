class Conversation < ActiveRecord::Base
  include PublicActivity::Common
  acts_as_paranoid
  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  has_many :conversation_changes
  belongs_to :last_closed_by, class_name: 'User'
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  before_validation :set_conversation_state, on: :create

  validates :family, :status, presence: true
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

  def broadcast_status(sender, new_status)
    channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newStatus#{user.email}"; channels}
    Pusher.trigger(channels, 'new_status', {new_status: new_status, conversation_id: id, changed_by: sender}) if channels.count > 0
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
