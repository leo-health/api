class Family < ActiveRecord::Base
  after_save :ensure_default_conversation_exists

  has_many :members, :class_name => 'User'
  has_many :conversations

  def primary_parent
    self.members.order('created_at ASC').first
  end

  #wuang-make sure the conversation.first method would grab the primary conversation
  def conversation
    ensure_default_conversation_exists
    self.conversations.first
  end

  def parents
    self.members.with_role :parent
  end

  def guardians
    self.members.with_role :guardian
  end

  def children
    self.members.with_role :child
  end

  private

  def ensure_default_conversation_exists
    setup_default_conversation if self.conversations.count == 0 
  end

  def setup_default_conversation
    conversation = Conversation.new
    conversation.family = self
    conversation.participants << self.parents
    conversation.save
  end
end
