class User < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  has_many :escalations, foreign_key: 'escalated_to_id'
  has_many :invitations, :class_name => self.to_s, :as => :invited_by
  has_many :sessions

  after_initialize :init
  rolify

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

  # Class variables, methods and properties to help better filter and retrieve records
  def self.for_user(user)
    # TODO. Think through this and design better
    my_family_id = user.family_id
    if user.has_role? :guardian
      User.joins(:roles).where{
        (family_id.eq(my_family_id)) | (roles.name.matches 'physician' )
    }
    elsif user.has_role? :patient
      [user]
    elsif user.has_role? :clinical
      #TODO: Implement
    elsif user.has_role? :clinical_support
      #TODO: Implement
    elsif user.has_role? :customer_service
      #TODO: Implement
    elsif user.has_role? :super_user
      User.all
    end
  end

  # Helper methods to render attributes in a more friednly way

  def is_patient?
    has_role? :patient
  end

  def email_required?
    (is_child?) ? false : super
  end

  def password_required?
    (is_child?) ? false : super
  end

  def primary_role
    roles.first.name if (roles and roles.count > 0)
  end

  def to_debug
    to_yaml
  end

  private
  # Since we only have one practice, default practice id to 1. Eventually we would like to capture this at registration or base the default value on patient visit history.
  def init
    self.practice_id ||= 1
  end
end
