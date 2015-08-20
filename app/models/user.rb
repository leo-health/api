class User < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :family
  belongs_to :practice
  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :read_receipts, foreign_key: "reader_id"
  has_many :read_messages, class_name: 'Message', through: :read_receipts
  has_many :invitations, as: :invited_by
  has_many :sessions
  has_many :sent_messages, foreign_key: "sender_id", class_name: "Message"
  has_many :escalated_messages, foreign_key: "escalated_by_id", class_name: "Message"
  has_many :escalations, foreign_key: "escalated_to_id", class_name: "Message"
  belongs_to :role

  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :password, length: {minimum: 8, allow_nil: true}
  validates :first_name, :last_name, :role, presence: true
  validates :email, presence: true, unless: Proc.new{|u|u.password.nil?}
  validates_uniqueness_of :email, allow_blank: true

  after_commit :set_user_family, on: :create

  def create_or_update_stripe_customer_id(token)
    Stripe.api_key = "sk_test_hEhhIHwQbmgg9lmpMz7eTn14"
    if customer = Stripe::Customer.create(:source => token, :description => self.id)
      update_attributes(stripe_customer_id: customer.id)
    end
  end

  def find_conversation_by_status(status)
    return if has_role? :guardian
    conversations.where(status: status)
  end

  def unread_conversations
    return if has_role? :guardian
    Conversation.includes(:user_conversations).where(id: user_conversations.where(read: false).pluck(:conversation_id)).order( updated_at: :desc).order( "user_conversations.priority desc" )
  end

  def escalated_conversations
    return if has_role? :guardian
    Conversation.includes(:user_conversations).where(id: user_conversations.where(escalated: true).pluck(:conversation_id)).order( updated_at: :desc).order( "user_conversations.priority desc" )
  end

  def add_role(name)
    new_role = Role.find_by_name(name)
    update_attributes(role: new_role) if new_role
  end

  def has_role? (name)
    role.name == name.to_s
  end

  private

  def set_user_family
    if has_role? :guardian
      update_attributes(family: Family.create) unless family
    end
  end
end
