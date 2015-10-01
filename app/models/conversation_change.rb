class ConversationChange < ActiveRecord::Base
  serialize :conversation, Hash

  belongs_to :conversation
  belongs_to :changed_by, class_name: 'User'
  validates :conversation, presence: true
end
