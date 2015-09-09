class Family < ActiveRecord::Base
  has_many :guardians, class_name: 'User'
  has_many :patients
  has_one :conversation

  after_commit :set_up_conversation, on: :create

  def members
   guardians + patients
  end

  def primary_parent
    guardians.order('created_at ASC').first
  end

  private

  def set_up_conversation
    Conversation.find_or_create_by(family_id: id, status: :open)
  end
end
