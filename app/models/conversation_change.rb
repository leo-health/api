class ConversationChange < ActiveRecord::Base
  serialize :conversation, Hash

  belongs_to :conversation
  validates :conversation, presence: true
end
