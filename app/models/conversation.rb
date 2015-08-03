class Conversation < ActiveRecord::Base
  has_many :messages
  has_many :user_conversations
  has_many :participants, class_name: "User", :through => :user_conversations
  belongs_to :family
  belongs_to :archived_by, class_name: 'User'

  after_initialize :load_initial_participants

  def load_initial_participants
    # TODO: Add a default admin staff
    # self.particpants << User.find_staff_for_user/family/child

    # TODO: Add a default physician
    # self.participants << User.find_physician_for_user/family/child

    # self.save
  end

  def self.for_user(user)
    if user.has_role? :guardian
      user.conversations
    elsif user.has_role? :patient
      #TODO: Implement
    elsif user.has_role? :clinical
      #TODO: Implement
    elsif user.has_role? :clinical_support
      #TODO: Implement
    elsif user.has_role? :customer_service
      #TODO: Implement
    elsif user.has_role? :super_user
      Conversation.all
    end
  end
end
