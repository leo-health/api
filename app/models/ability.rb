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
      can :read, Conversation
    elsif user.has_role? :clinical
      can :read, Conversation
    elsif user.has_role? :clinical_support
      can :read, Conversation
    elsif user.has_role? :customer_service
      can :read, Conversation
    end
  end
end
