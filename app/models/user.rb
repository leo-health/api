class User < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  has_many :escalations, foreign_key: 'escalated_to_id'
  has_many :invitations, :class_name => self.to_s, :as => :invited_by
  has_many :sessions
  belongs_to :role

  after_initialize :set_default_practice

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

  def add_role(name)
    update_attributes(role: role) if role = Role.find_by_name(name)
  end

  def has_role? (name)
    role.name == name
  end

  def is_patient?
    has_role? :patient
  end

  private
  def set_default_practice
    self.practice_id ||= 1
  end

  def set_user_family
    update_attributes(family: Family.create) unless family
  end
end
