class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can [:read, :update, :destroy], Patient, :family_id => user.family_id
      can :read, Conversation, :family_id => user.family_id
      can :read, Message, :sender_id => user.id
      can :create, Message, :conversation_id => Conversation.find_by_family_id(user.family_id).id
    elsif user.has_role? :financial
      can [:read, :update], Conversation
      can [:read, :update], Message
    elsif user.has_role? :clinical
      can [:read, :update], Conversation
      can [:read, :update], Message
    elsif user.has_role? :clinical_support
      can [:read, :update], Conversation
      can [:read, :update], Message
    elsif user.has_role? :customer_service
      can [:read, :update], Conversation
      can [:read, :update], Message
    end
  end
end
