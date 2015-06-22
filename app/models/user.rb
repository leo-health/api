# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  title                  :string           default("")
#  first_name             :string           default(""), not null
#  middle_initial         :string           default("")
#  last_name              :string           default(""), not null
#  dob                    :datetime
#  sex                    :string
#  practice_id            :integer
#  email                  :string           default(""), not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime
#  updated_at             :datetime
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  authentication_token   :string
#  family_id              :integer
#

class User < ActiveRecord::Base
  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  has_many :escalations, foreign_key: 'escalated_to_id'
  has_many :invitations, :class_name => self.to_s, :as => :invited_by

  after_initialize :init
  rolify
  acts_as_token_authenticatable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, unless: :is_child?

  ROLES = {
  			# Admin is 1
  			admin: 1,
  			# Leo users are 10-19
  			physician: 11,
  			clinical_staff: 12,
  			other_staff: 13,
  			# Leo customers are 20-29
  			parent: 21,
  			child: 22,
  			guardian: 23
  		}

  # GET /roles

  has_one :patient
  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  # has_and_belongs_to_many :conversations, foreign_key: 'child_id', join_table: 'conversations_children'
  has_many :escalations, foreign_key: 'escalated_to_id'
  has_many :invitations, :class_name => self.to_s, :as => :invited_by

  def reset_authentication_token
  	update_attribute(:authentication_token, nil)
  end

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
    if user.has_role? :parent
      User.joins(:roles).where{
        (family_id.eq(my_family_id)) | (roles.name.matches 'physician' )
      }
      
    elsif user.has_role? :guardian
      User.joins(:roles).where{
        (family_id.eq(my_family_id)) | (roles.name.matches 'physician' )
      }
      
    elsif user.has_role? :child
      [user]
    elsif user.has_role? :physician
      #TODO: Implement
    elsif user.has_role? :clinical_staff
      #TODO: Implement
    elsif user.has_role? :other_staff
      #TODO: Implement
    elsif user.has_role? :admin
      User.all
    end
  end

  # Helper methods to render attributes in a more friednly way

  def is_child?
    has_role? :child
  end

  def email_required?
    (is_child?) ? false :super
  end

  def password_required?
    (is_child?) ? false : super
  end

  def primary_role
    roles.first.name if (roles and roles.count > 0)
  end

  # Since we only have one practice, default practice id to 1. Eventually we would like to capture this at registration or base the default value on patient visit history.
  def init
    self.practice_id ||= 1
  end

  def to_debug
    to_yaml
  end
end
