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
    Conversation.create(family_id: id, state: :closed) unless Conversation.find_by_family_id(id)
  end
end
