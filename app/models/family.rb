class Family < ActiveRecord::Base
  include AASM

  has_many :guardians, class_name: 'User'
  has_many :patients
  has_one :conversation

  validates_presence_of :membership_type

  after_commit :set_up_conversation, on: :create

  class << self
    def new_from_enrollment(enrollment)

      # TODO: ????: How to handle secondary guardian?
      family = nil
      ActiveRecord::Base.transaction do
        user = User.new_from_enrollment enrollment
        user.save!
        enrollment.patient_enrollments.each do |patient_enrollment|
          Patient.new_from_patient_enrollment patient_enrollment
        end
        family = user.family
      end
      family
    end
  end

  aasm whiny_transitions: false, column: :membership_type do
    state :incomplete, initial: true
    state :delinquent
    state :member
    state :exempted

    event :renew_membership do
      transitions from: [:incomplete, :delinquent], to: :member
    end

    event :expire_membership do
      transitions from: :member, to: :delinquent
    end

    event :exempt_membership do
      transitions to: :exempted
    end
  end

  def members
   guardians + patients
  end

  def primary_guardian
    guardians.order('created_at ASC').first
  end

  private

  def set_up_conversation
    Conversation.create(family_id: id, state: :closed) unless Conversation.find_by_family_id(id)
  end
end
