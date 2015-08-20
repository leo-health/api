class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can :read, User, :role_id => [1, 2, 3, 4, 5]
      can [:create, :update, :destroy], User, :family_id => user.family_id
      can [:read, :update, :destroy], Patient, :family_id => user.family_id
      can :read, Conversation, :family_id => user.family_id
      can :read, Message, :sender_id => user.id
      can :create, Message, :conversation_id => Conversation.find_by_family_id(user.family_id).id
    elsif user.has_role? :financial
      can :read, User, :role_id => [1, 2, 3, 4, 5]
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :update, UserConversation
    elsif user.has_role? :clinical
      can [:read, :update, :destroy, :create], User, :role_id => [1, 2, 3, 4, 5]
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :update, UserConversation
    elsif user.has_role? :clinical_support
      can [:read, :update, :destroy, :create], User, :role_id => [1, 2, 3, 4, 5]
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :update, UserConversation
    elsif user.has_role? :customer_service
      can :read, User, :role_id => [1, 2, 3, 4, 5]
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :update, UserConversation
    end
  end
end
