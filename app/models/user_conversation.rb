class UserConversation < ActiveRecord::Base
  belongs_to :staff, ->{where('role_id != ?', 4)}, foreign_key: "user_id", class_name: "User"
  belongs_to :conversation, foreign_key: "conversation_id"
  has_many :escalation_notes

  validates :staff, :conversation, presence: true
  validates_uniqueness_of :user_id, scope: :conversation_id
end
