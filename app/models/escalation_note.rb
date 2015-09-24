class EscalationNote < ActiveRecord::Base
  belongs_to :message
  belongs_to :assignor,  ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :assignee,  ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :assignor, :assignee, :message, :priority_level, presence: true
end
