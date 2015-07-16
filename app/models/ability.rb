class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    alias_action :create, :read, :update, :destory, :to => :crud

    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can :crud, User, :id => user.family.members.with_role(:patient).pluck(:id)
    end
  end
end
