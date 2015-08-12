class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can [:read, :update, :destroy], Patient, :family_id => user.family_id
    elsif user.has_role? :financial
      can :read, User, :role_id => [1, 2, 3, 4, 5]
    elsif user.has_role? :clinical
      can :read, User, :role_id => [1, 2, 3, 4, 5]
    elsif user.has_role? :clinical_support
      can :read, User, :role_id => [1, 2, 3, 4, 5]
    elsif user.has_role? :customer_service
      can :read, User, :role_id => [1, 2, 3, 4, 5]
    end
  end
end
