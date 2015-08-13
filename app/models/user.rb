class User < ActiveRecord::Base
  belongs_to :family
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :read_receipts, foreign_key: "reader_id"
  has_many :read_messages, class_name: 'Message', through: :read_receipts
  has_many :invitations, as: :invited_by
  has_many :sessions
  has_many :user_roles, inverse_of: :user
  has_many :roles, through: :user_roles
  has_many :sent_messages, foreign_key: "sender_id", class_name: "Message"
  has_many :escalated_messages, foreign_key: "escalated_by_id", class_name: "Message"
  has_many :escalations, foreign_key: "escalated_to_id", class_name: "Message"

  after_initialize :set_default_practice

  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :password, length: {minimum: 8, allow_nil: true}
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, unless: Proc.new{|u|u.password.nil?}
  validates_uniqueness_of :email, allow_blank: true

  def create_or_update_stripe_customer_id(token)
    Stripe.api_key = "sk_test_hEhhIHwQbmgg9lmpMz7eTn14"

    if customer = Stripe::Customer.create(:source => token, :description => self.id)
      update_attributes(stripe_customer_id: customer.id)
    end
  end

  def unread_conversations
    return if has_role? :guardian
    Conversation.where(id: user_conversations.where(read: false).pluck(:conversation_id))
  end

  def escalated_conversations
    return if has_role? :guardian
    Conversation.where(id: user_conversations.where(esclated: true).pluck(:conversation_id))
  end

  def has_role? (name)
    !!roles.find_by_name(name)
  end

  def add_role(name)
    role = Role.find_by_name(name)
    roles << role if role
  end

  def is_patient?
    has_role? :patient
  end

  private
  def set_default_practice
    self.practice_id ||= 1
  end
end
