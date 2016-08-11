class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :guardian
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical).include? (user.role.name)
      end
      can [:read, :create, :update, :destroy], User, family_id: user.family_id
      can [:create, :read, :update, :destroy], Patient, family_id: user.family_id
      can :read, Conversation, family_id: user.family_id
      can [:read, :create], Message, conversation_id: Conversation.find_by_family_id(user.family_id).try(:id)
      can [:create, :read, :destroy], Appointment, patient: {family_id: user.family_id}
      can :create, Avatar, owner_type: "Patient", owner_id: patient_ids(user)
      can [:read, :update, :destroy], Form, patient_id: patient_ids(user)
    elsif user.has_role? :financial
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :read, Appointment
      can :update, UserConversation
      can :read, EscalationNote
      can :read, Session
    elsif user.has_role? :clinical
      can [:read, :update], User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :read, Appointment
      can :update, UserConversation
      can :read, EscalationNote
      can [:read, :update, :destroy], Form
      can :read, Session
    elsif user.has_role? :clinical_support
      can [:read, :update], User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :read, Appointment
      can :update, UserConversation
      can :read, EscalationNote
      can [:read, :update, :destroy], Form
      can :read, Session
    elsif user.has_role? :customer_service
      can :read, User do |user|
        %w(financial clinical_support customer_service clinical guardian).include? (user.role.name)
      end
      can [:read, :update], Conversation
      can [:create, :read], Message
      can :update, UserConversation
      can :read, EscalationNote
      can :read, Form
      can :read, Session
    elsif user.has_role? :operational
      can :read, Session
      can [:read, :update], Conversation
    end
  end

  private

  def patient_ids(guardian)
    Family.find(guardian.family_id).patients.pluck(:id)
  end
end
