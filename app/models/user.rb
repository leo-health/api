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
#  sign_in_count          :integer          default("0"), not null
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
#  invitations_count      :integer          default("0")
#  authentication_token   :string
#  family_id              :integer
#

class User < ActiveRecord::Base
  rolify
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, :email,  presence: true

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

  belongs_to :family
  has_and_belongs_to_many :conversations, foreign_key: 'participant_id', join_table: 'conversations_participants'
  # has_and_belongs_to_many :conversations, foreign_key: 'child_id', join_table: 'conversations_children'

  def reset_authentication_token
  	u.update_attribute(:authentication_token, nil)
  end

  # Class variables, methods and properties to help better filter and retrieve records

  def self.for_user(user)
    # TODO. Think through this and design better
    if user.has_role? :parent
      user.family.members
    elsif user.has_role? :guardian
      user.family.members
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

  def primary_role
    self.roles.first.name
  end


end
