class Conversation < ActiveRecord::Base
  has_many :messages
  has_many :user_conversations
  has_many :participants, class_name: "User", :through => :user_conversations
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  validates :family, presence: true
  after_create :load_initial_participants

  def load_initial_participants
    participants << family.members
  end
end
