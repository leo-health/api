class User < ActiveRecord::Base
  include RoleCheckable
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :validatable
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

  scope :incomplete, -> { where(complete: false) }
  scope :complete, -> { where(complete: true) }
  scope :guardians, -> { where(role: Role.guardian_roles, complete: true) }
  scope :staff, -> { where(role: Role.staff_roles, complete: true) }
  scope :clinical_staff, -> { where(role: Role.clinical_staff_roles, complete: true) }
  scope :provider, -> { where(role: Role.provider_roles, complete: true) }

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
  validates_confirmation_of :password
  validates :first_name, :last_name, :role, :phone, :encrypted_password, :practice, presence: true
  validates :provider, presence: true, if: :clinical?
  validates :family, :vendor_id, presence: true, if: :guardian?
  validates :password, presence: true, if: :password_required?
  validates_uniqueness_of :vendor_id, allow_blank: true
  after_validation :user_is_complete_callback

  before_create :confirmation_task
  after_commit :guardian_was_confirmed_callback, if: :guardian?

  class << self
    def customer_service_user
      User.joins(:role).where(roles: { name: "customer_service" }).order("created_at ASC").first
    end

    def leo_bot
      leo_bot_id = $redis.get "leo_bot_id"
      leo_bot = self.find_by(id: leo_bot_id) || self.unscoped.find_by_email("leo_bot@leohealth.com")
      if leo_bot
        $redis.set "leo_bot_id", leo_bot.id
      end
      leo_bot
    end
  end

  # Question properties
  def incomplete?
    !complete
  end

  def complete?
    complete
  end

  def never_send_confirmation_email?
    invited_user?
  end

  def invited_user?
    onboarding_group.try(:invited_secondary_guardian?)
  end

  def primary_guardian?
    return false unless guardian?
    User.where('family_id = ? AND created_at < ?', family_id, created_at).count < 1
  end

  # Calculated properties
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
    if invited_user? && incomplete?
      sessions.first.try(:authentication_token)
    end
  end

  # Actions
  def upgrade!
    update_attributes(type: :Member) if guardian?
  end

  def collect_device_tokens
    sessions.map{|session| session.device_token}.compact.uniq
  end

  private

  # Callbacks
  def confirmation_task
    if never_send_confirmation_email?
      skip_confirmation! # permanently marks as confirmed
    elsif incomplete?
      skip_confirmation_notification!
    end
  end

  def user_is_complete_callback
    was_incomplete = incomplete?
    update_attribute(:complete, self.errors.empty?)

    if complete? && was_incomplete
      if !primary_guardian? && guardian?
        self.confirm
        update_attribute(:type, family.primary_guardian.type)
        InternalInvitationEnrollmentNotificationJob.send(id)
      end
      send_confirmation_instructions if unconfirmed_email
    end
  end

  def password_required?
    encrypted_password ? false : super
  end

  def add_family_to_guardian
    self.family ||= Family.create if primary_guardian?
  end

  def add_default_practice_to_guardian
    self.practice ||= Practice.first
  end

  def guardian_was_confirmed_callback
    if confirmed_at_changed? && guardian?
      WelcomeToPracticeJob.send(id)
    end
  end

  def format_phone_number
    self.phone = phone.scan(/\d+/).join[-10..-1] if phone
  end
end
