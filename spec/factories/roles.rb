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

FactoryGirl.define do
  factory :role do
  	id     99
  	name   :guest

  	trait :admin do
  		id    1
  		name  :admin
  	end

  	trait :parent do
      id    21
      name  :parent
    end

    trait :child do
      id    22
      name  :child
    end

    trait :physician do
      id    11
      name  :physician
    end
  end
 end
