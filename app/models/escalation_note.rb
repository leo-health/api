class EscalationNote < ActiveRecord::Base
  belongs_to :user_conversation
  belongs_to :escalated_by,  ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :escalated_to, :escalated_by, :conversation, :priority, presence: true
end
