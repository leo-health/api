class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can :manage, User, :id => user.family.members.with_role(:patient).pluck(:id)
    end
  end
end
