class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can [:read, :update, :destroy], Patient, :family_id => user.family_id
      can :read, Conversation, :family_id => user.family_id
    elsif user.has_role? :financial
      can [:read, :update, :destroy], Conversation
    elsif user.has_role? :clinical
      can [:read, :update, :destroy], Conversation
    elsif user.has_role? :clinical_support
      can [:read, :update, :destroy], Conversation
    elsif user.has_role? :customer_service
      can [:read, :update, :destroy], Conversation
    end
  end
end
