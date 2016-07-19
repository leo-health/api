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
  scope :provider, -> { where(role: Role.provider_roles, complete_status: :complete) }
  scope :completed_or_athena, ->{ self.joins('LEFT OUTER JOIN onboarding_groups on users.onboarding_group_id = onboarding_groups.id')
                                      .where('complete_status=? OR onboarding_groups.group_name=?', 'complete', 'generated_from_athena') }
  belongs_to :family
  belongs_to :role
  belongs_to :practice
  belongs_to :onboarding_group
  belongs_to :insurance_plan
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

  before_validation :format_phone_number
  before_validation :set_up_guardian, if: :guardian?
  validates_presence_of :email
  validates_uniqueness_of :email, conditions: -> { completed_or_athena }
  validates_format_of :email, with: Devise.email_regexp
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates :first_name, :last_name, :role, :phone, :encrypted_password, :practice, presence: true, if: :should_validate_for_completion?
  validates :provider, presence: true, if: :clinical?
  validates_uniqueness_of :invitation_token, :vendor_id, allow_nil: true
  before_save :set_completion_state_by_validation, unless: :complete?
  before_create :skip_confirmation_task_if_needed_callback

  EXPIRATION_PERIOD = 7.days

  def self.customer_service_user
    User.where(role: Role.customer_service).order("created_at ASC").first
  end

  def self.leo_bot
    leo_bot_id = $redis.get "leo_bot_id"
    leo_bot = self.find_by(id: leo_bot_id) || self.unscoped.find_by_email("leo_bot@leohealth.com")
    if leo_bot
      $redis.set("leo_bot_id", leo_bot.id)
    end
    leo_bot
  end

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

  def invited_user?
    onboarding_group.try(:invited_secondary_guardian?)
  end

  def exempted_user?
    onboarding_group.try(:generated_from_athena?)
  end

  def primary_guardian?
    return false unless guardian?
    User.where('family_id = ? AND created_at < ?', family_id, created_at).count < 1
  end

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def collect_device_tokens
    sessions.map{|session| session.device_token}.compact.uniq
  end

  def confirm_secondary_guardian
    confirm
    set_complete
    save
  end

  def guardian_was_approved?
    return true unless guardian?
    return true if primary_guardian?
    confirmed?
  end

  def reset_invitation_token
    self.invitation_token = GenericHelper.generate_token(:invitation_token)
    save
  end

  def invitation_token_expired?
    invitation_sent_at ? (Time.now - EXPIRATION_PERIOD) < invitation_sent_at : false
  end

  private

  def prevalidate_for_completion
    return true if complete?
    old_complete_status = complete_status
    # test validity without callbacks
    self.complete_status = :valid_incomplete
    valid_for_completion = valid?
    self.complete_status = old_complete_status
    valid_for_completion
  end

  def set_up_guardian
    add_default_practice_to_guardian
    add_family_to_guardian
    add_vendor_id
    ensure_invitation_token
  end

  def add_default_practice_to_guardian
    self.practice ||= Practice.first
  end

  def add_family_to_guardian
    self.family ||= Family.create if primary_guardian?
  end

  def format_phone_number
    self.phone = phone.scan(/\d+/).join[-10..-1] if phone
  end

  def add_vendor_id
    self.vendor_id ||= GenericHelper.generate_token(:vendor_id)
  end

  def ensure_invitation_token
    self.invitation_token ||= GenericHelper.generate_token(:invitation_token) if (invited_user? || exempted_user?)
  end

  def skip_confirmation_task_if_needed_callback
    skip_confirmation_notification! unless complete?
  end

  def password_required?
    return false unless complete?
    encrypted_password ? false : super
  end

  def guardian_was_completed_callback
    WelcomeToPracticeJob.send(id)
    send_confirmation_instructions unless confirmed?
    Conversation.create(family: family) unless Conversation.find_by_family_id(family.id)
  end
end
