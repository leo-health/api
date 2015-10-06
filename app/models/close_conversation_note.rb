class CloseConversationNote < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :closed_by, ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :conversation, :closed_by, presence: true
end
