class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    alias_action :create, :read, :to => :crud

    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can :read, User, :patient_user => id: user.family.patients.pluck(:id)
    end
  end
end
