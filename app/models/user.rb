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
#  role                   :integer          not null
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
#  customer_type          :integer
#  staff_type             :integer
#

class User < ActiveRecord::Base
  rolify
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, :role, :email,  presence: true

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

  
end
