class User < ActiveRecord::Base
  include RoleCheckable, AASM
  devise :database_authenticatable, :registerable, :confirmable, :recoverable
  acts_as_paranoid
  include PgSearch
  pg_search_scope(
    :search,
    against: %i( first_name last_name ),
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.3 }
    }
  )

  scope :incomplete, -> { where.not(complete_status: :complete) }
  scope :complete, -> { where(complete_status: :complete) }
  scope :guardians, -> { where(role: Role.guardian_roles, complete_status: :complete) }
  scope :staff, -> { where(role: Role.staff_roles, complete_status: :complete) }
  scope :clinical_staff, -> { where(role: Role.clinical_staff_roles, complete_status: :complete) }
  scope :provider, -> { where(role: Role.provider_roles, complete_status: :complete) }

  belongs_to :family
  belongs_to :role
  belongs_to :practice
  belongs_to :onboarding_group
  belongs_to :insurance_plan
  belongs_to :enrollment
  has_one :avatar, as: :owner
  has_one :staff_profile, foreign_key: "staff_id", inverse_of: :staff
  accepts_nested_attributes_for :staff_profile
  has_one :provider, inverse_of: :user
  accepts_nested_attributes_for :provider
  has_many :forms, foreign_key: "submitted_by_id"
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :read_receipts, foreign_key: "reader_id"
  has_many :escalated_notes, foreign_key: "escalated_by_id"
  has_many :escalation_notes, foreign_key: "escalated_to_id"
  has_many :closure_notes, foreign_key: "closed_by_id"
  has_many :read_messages, class_name: 'Message', through: :read_receipts
  has_many :sessions
  has_many :sent_messages, foreign_key: "sender_id", class_name: "Message"
  has_many :booked_appointments, -> { Appointment.booked }, foreign_key: "booked_by_id", class_name: "Appointment"
  has_many :user_generated_health_records

  before_validation :add_default_practice_to_guardian, :add_family_to_guardian, :format_phone_number, if: :guardian?

  validates_presence_of   :email
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?, conditions: -> { complete.where(deleted_at: nil) }
  validates_format_of     :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password
  validates_length_of       :password, within: Devise.password_length, allow_blank: true

  validates :first_name, :last_name, :role, :phone, :encrypted_password, :practice, presence: true, if: :should_validate_for_completion?
  validates :family, :vendor_id, presence: true, if: Proc.new { |u| u.guardian? && u.should_validate_for_completion? }
  validates :provider, presence: true, if: :clinical?
  validates_uniqueness_of :vendor_id, allow_blank: true

  before_save :set_completion_state_by_validation, unless: :complete?
  before_create :skip_confirmation_task_if_needed_callback

  aasm whiny_transitions: false, column: :complete_status do
    state :incomplete, initial: true
    state :valid_incomplete
    state :complete

    event :set_complete do
      after do
        guardian_was_completed_callback if guardian?
      end

      transitions from: :valid_incomplete, to: :complete, guard: :guardian_was_approved?
    end

    event :set_valid_incomplete do
      transitions to: :valid_incomplete
    end

    event :set_incomplete do
      transitions to: :incomplete
    end
  end

  def stripe_customer_id
    family.try(:stripe_customer_id)
  end

  def membership_type
    family.try(:membership_type)
  end

  def should_validate_for_completion?
    !incomplete?
  end

  def set_completion_state_by_validation
    set_valid_incomplete if !complete? && prevalidate_for_completion
    complete_status
  end

  def prevalidate_for_completion
    return true if complete?
    old_complete_status = complete_status
    # test validity without callbacks
    self.complete_status = :valid_incomplete
    valid_for_completion = valid?
    self.complete_status = old_complete_status
    valid_for_completion
  end

  def invited_user?
    onboarding_group.try(:invited_secondary_guardian?)
  end

  def primary_guardian?
    return false unless guardian?
    User.where('family_id = ? AND created_at < ?', family_id, created_at).count < 1
  end

  def find_conversation_by_status(status)
    return if guardian?
    conversations.where(status: status)
  end

  def unread_conversations
    return if guardian?
    Conversation.includes(:user_conversations).where(id: user_conversations.where(read: false).pluck(:conversation_id)).order( updated_at: :desc)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def invitation_token
    if invited_user? && !complete?
      session = sessions.first || create_onboarding_session
      session.authentication_token
    end
  end

  def upgrade!
    update_attributes(type: :Member) if guardian?
  end

  def collect_device_tokens
    sessions.map{|session| session.device_token}.compact.uniq
  end

  def confirm_secondary_guardian
    confirm
    set_complete
    self.type = family.primary_guardian.type
    save
  end

  def guardian_was_approved?
    return true unless guardian?
    return true if primary_guardian?
    confirmed?
  end

  def create_onboarding_session(**session_params)
    sessions.create(session_params.reverse_merge(onboarding_group: onboarding_group))
  end

  class << self
    def customer_service_user
      User.joins(:role).where(roles: { name: "customer_service" }).order("created_at ASC").first
    end

    def leo_bot
      leo_bot_id = $redis.get "leo_bot_id"
      leo_bot = self.find_by(id: leo_bot_id) || self.unscoped.find_by_email("leo_bot@leohealth.com")
      if leo_bot
        $redis.set("leo_bot_id", leo_bot.id)
      end
      leo_bot
    end

    def email_taken?(email)
      return true if User.complete.find_by(email: email)
      return true if User.where(email: email)
        .includes(:onboarding_group)
        .where(onboarding_group: { group_name: "generated_from_athena" })
        .first
    end
  end

  private

  def skip_confirmation_task_if_needed_callback
    skip_confirmation_notification! if !complete?
  end

  def password_required?
    return false if !complete?
    encrypted_password ? false : super
  end

  def add_family_to_guardian
    self.family ||= Family.create if primary_guardian?
  end

  def add_default_practice_to_guardian
    self.practice ||= Practice.first
  end

  def guardian_was_completed_callback
    if complete?
      WelcomeToPracticeJob.send(id)
      send_confirmation_instructions unless confirmed?
      Conversation.create(family_id: family.id, state: :closed) unless Conversation.find_by_family_id(family.id)
    end
  end

  def format_phone_number
    self.phone = phone.scan(/\d+/).join[-10..-1] if phone
  end
end
