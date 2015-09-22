class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_user
      can :manage, :all
    elsif user.has_role? :guardian
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical).include? (user.role.name)
      end
      can [:read, :create, :update, :destroy], User, :family_id => user.family_id
      can [:create, :read, :update, :destroy], Patient, :family_id => user.family_id
      can :read, Conversation, :family_id => user.family_id
      can :read, Message, :conversation_id => Conversation.find_by_family_id(user.family_id).id
      can [:read, :create], Message, :conversation_id => Conversation.find_by_family_id(user.family_id).id
      can [:create, :read, :destroy], Appointment, :booked_by_id => user.id
      can :create, Avatar, :owner_type => "Patient", :owner_id => Family.find(user.family_id).patients.pluck(:id)
    elsif user.has_role? :financial
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :read, Appointment
      can :update, UserConversation
    elsif user.has_role? :clinical
      can [:read, :update], User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :read, Appointment
      can :update, UserConversation
    elsif user.has_role? :clinical_support
      can [:read, :update], User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :read, Appointment
      can :update, UserConversation
    elsif user.has_role? :customer_service
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, Message, :escalated_at => nil
      can :update, UserConversation
    end
  end
end
