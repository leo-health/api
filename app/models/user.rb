class User < ActiveRecord::Base
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

  belongs_to :family
  belongs_to :role
  belongs_to :practice
  belongs_to :onboarding_group
  belongs_to :insurance_plan
  has_one :avatar, as: :owner
  has_one :staff_profile, foreign_key: "staff_id"
  has_one :provider_sync_profile, foreign_key: "provider_id"
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
  has_many :provider_appointments, foreign_key: "provider_id", class_name: "Appointment"
  has_many :booked_appointments, foreign_key: "booked_by_id", class_name: "Appointment"
  has_many :user_generated_health_records

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :validatable

  before_validation :add_default_practice_to_guardian

  validates_confirmation_of :password
  validates :first_name, :last_name, :role, :phone, :encrypted_password, presence: true
  validates :password, presence: true, if: :password_required?
  validates_uniqueness_of :email, conditions: -> { where(deleted_at: nil)}

  after_update :welcome_to_practice_email, :notify_primary_guardian
  after_commit :set_user_family, :remind_schedule_appointment, on: :create

  def self.customer_service_user
    self.joins(:role).where(roles: {name: "customer_service"}).order("created_at ASC").first
  end

  def self.staff
    User.includes(:role).where.not(roles: {name: :guardian})
  end

  def self.leo_bot
    @leo_bot ||= self.unscoped.find_by_email("leo_bot@leohealth.com")
  end

  def find_conversation_by_status(status)
    return if has_role? :guardian
    conversations.where(status: status)
  end

  def unread_conversations
    return if has_role? :guardian
    Conversation.includes(:user_conversations).where(id: user_conversations.where(read: false).pluck(:conversation_id)).order( updated_at: :desc)
  end

  def add_role(name)
    new_role = Role.find_by_name(name)
    update_attributes(role: new_role) if new_role
  end

  def has_role? (name)
    role && role.name == name.to_s
  end

  def upgrade!
    update_attributes(type: :Member) if has_role? :guardian
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def primary_guardian?
    return false unless has_role? :guardian
    User.where('family_id = ? AND created_at < ?', family_id, created_at).count < 1
  end

  private

  def welcome_to_practice_email
    WelcomeToPracticeJob.send(self.id) if guardian_confirmed_email?
  end

  def notify_primary_guardian
    if invited_guardian_confirmed_email? && sender = User.leo_bot
      family.conversation.messages.create( body: "#{first_name} has joined Leo",
                                           sender: sender,
                                           type_name: :text
                                          )

    end
  end

  def guardian_confirmed_email?
    (confirmed_at_changed?) && (has_role? :guardian)
  end

  def invited_guardian_confirmed_email?
    onboarding_group.try(:invited_secondary_guardian?) && guardian_confirmed_email?
  end

  def remind_schedule_appointment
    RemindScheduleAppointmentJob.send(self.id) if has_role? :guardian
  end

  def password_required?
    encrypted_password ? false : super
  end

  def set_user_family
    if has_role? :guardian
      update_attributes(family: Family.create) unless family
    end
  end

  def add_default_practice_to_guardian
    practice ||= Practice.first if has_role? :guardian
  end
end
