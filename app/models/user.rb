class User < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  has_many :escalations, foreign_key: 'escalated_to_id'
  has_many :invitations, :class_name => self.to_s, :as => :invited_by
  has_many :sessions
  has_many :user_roles
  has_many :roles, :through => :user_roles

  after_initialize :set_default_practice

  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :password, length: {minimum: 8, allow_nil: true}
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, unless: :is_patient?
  validates_uniqueness_of :email

  def create_or_update_stripe_customer_id(token)
    Stripe.api_key = "sk_test_hEhhIHwQbmgg9lmpMz7eTn14"

    # Create a Stripe Customer
    if customer = Stripe::Customer.create(:source => token, :description => self.id)
      update_attributes(stripe_customer_id: customer.id)
    end
  end

  def has_role? (name)
    !!roles.find_by_name(name)
  end

  def add_role(name)
    role = Role.find_by_name(name) || Role.create(name: name)
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
