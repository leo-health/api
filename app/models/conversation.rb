class Conversation < ActiveRecord::Base
  has_many :messages
  has_many :user_conversations
  has_many :staff, class_name: "User", :through => :user_conversations
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  validates :family, presence: true
  after_create :load_staff

  def load_staff
    #define whom are the staff members to be add into a conversation
  end
end
