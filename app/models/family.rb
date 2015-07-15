class Family < ActiveRecord::Base
  has_many :guardians,
  has_many :patients
  has_many :conversations

  after_save :ensure_default_conversation_exists

  def primary_parent
    self.members.order('created_at ASC').first
  end

  #wuang-make sure the conversation.first method would grab the primary conversation
  def conversation
    ensure_default_conversation_exists
    self.conversations.first
  end

  def guardians
    self.members.with_role :guardian
  end

  def patients
    self.members.with_role :patient
  end

  private

  def ensure_default_conversation_exists
    setup_default_conversation if self.conversations.count == 0
  end

  def setup_default_conversation
    conversation = Conversation.new
    conversation.family = self
    conversation.participants << self.guardians
    conversation.save
  end
end
