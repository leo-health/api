class Family < ActiveRecord::Base
  has_many :guardians, foreign_key: 'family_id', class_name: 'User'
  has_many :patients
  has_one :conversation

  after_save :set_up_conversation

  def members
   guardians + patients
  end

  def primary_parent
    members.order('created_at ASC').first
  end

  private

  def set_up_conversation
    conversation.create unless conversation
  end
end
