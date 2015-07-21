class Family < ActiveRecord::Base
  has_many :members, :class_name => 'User'
  has_many :patients
  has_many :conversations

  # after_save :ensure_default_conversation_exists

  def primary_parent
    self.members.order('created_at ASC').first
  end

  def conversation
    ensure_default_conversation_exists
    conversations.first
  end

  private

  # def ensure_default_conversation_exists
  #   setup_default_conversation if self.conversations.count == 0
  # end
  #
  # def setup_default_conversation
  #   conversation = Conversation.new
  #   conversation.family = self
  #   conversation.participants << self.guardians
  #   conversation.save
  # end
end
