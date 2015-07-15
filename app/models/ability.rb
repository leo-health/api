class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    end

    if user.has_role? :guardian
      can :manage, User.where(role: 'child')
    end
  end
end
