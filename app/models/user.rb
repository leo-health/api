class User < ActiveRecord::Base
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

  scope :guardians, -> { where(role: Role.guardian_roles) }
  scope :staff, -> { where(role: Role.staff_roles) }
  scope :clinical_staff, -> { where(role: Role.clinical_staff_roles) }
  scope :provider, -> { where(role: Role.provider_roles) }
  belongs_to :family
  belongs_to :role
  belongs_to :practice
  belongs_to :onboarding_group
  belongs_to :insurance_plan
  has_one :avatar, as: :owner
  has_one :staff_profile, foreign_key: "staff_id", inverse_of: :staff
  accepts_nested_attributes_for :staff_profile
  has_one :provider_sync_profile, foreign_key: "provider_id", inverse_of: :provider
  accepts_nested_attributes_for :provider_sync_profile
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
  has_many :provider_appointments, -> { Appointment.booked }, foreign_key: "provider_id", class_name: "Appointment"
  has_many :booked_appointments, -> { Appointment.booked }, foreign_key: "booked_by_id", class_name: "Appointment"
  has_many :user_generated_health_records
  before_validation :add_default_practice_to_guardian, :add_family_to_guardian, :format_phone_number, if: :guardian?
  validates_confirmation_of :password
  validates :first_name, :last_name, :role, :phone, :encrypted_password, :practice, presence: true
  validates :provider_sync_profile, presence: true, if: :provider?
  validates :family, presence: true, if: :guardian?
  validates :password, presence: true, if: :password_required?
  validates_uniqueness_of :email, conditions: -> { where(deleted_at: nil) }
  after_update :welcome_onboarding_notifications, if: :guardian?
  after_commit :set_user_type_on_secondary_user, on: :create, if: :guardian?

  def self.customer_service_user
    User.joins(:role).where(roles: { name: "customer_service" }).order("created_at ASC").first
  end

  def self.leo_bot
    @leo_bot ||= self.unscoped.find_by_email("leo_bot@leohealth.com")
  end

  def find_conversation_by_status(status)
    return if guardian?
    conversations.where(status: status)
  end

  def unread_conversations
    return if guardian?
    Conversation.includes(:user_conversations).where(id: user_conversations.where(read: false).pluck(:conversation_id)).order( updated_at: :desc)
  end

  def add_role(name)
    new_role = Role.find_by_name(name)
    update_attributes(role: new_role) if new_role
  end

  def guardian?
    has_role? :guardian
  end

  def provider?
    has_role? :clinical
  end

  def has_role? (name)
    role && role.name == name.to_s
  end

  def upgrade!
    update_attributes(type: :Member) if guardian?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def primary_guardian?
    return false unless guardian?
    User.where('family_id = ? AND created_at < ?', family_id, created_at).count < 1
  end

  def collect_device_tokens
    sessions.map{|session| session.device_token}.compact.uniq
  end

  private

  def password_required?
    encrypted_password ? false : super
  end

  def welcome_onboarding_notifications
    if confirmed_at_changed? && guardian?
      WelcomeToPracticeJob.send(id)
    end
  end

  def add_family_to_guardian
    self.family ||= Family.create if primary_guardian?
  end

  def add_default_practice_to_guardian
    self.practice ||= Practice.first
  end

  def set_user_type_on_secondary_user
    unless primary_guardian?
      update_columns(type: family.primary_guardian.type)
      InternalInvitationEnrollmentNotificationJob.send(id)
    end
  end

  def format_phone_number
    self.phone = phone.scan(/\d+/).join[-10..-1] if phone
  end
end
