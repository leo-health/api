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
#  gender                    :string
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

FactoryGirl.define do
  sequence :email do |n|
  "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    dob 				{ 29.years.ago.to_s }
    gender					{ ['M', 'F'].sample }
    email
    password    'fake_pass'
    password_confirmation    'fake_pass'
    family_id    11
    association :family, factory: :family

    after(:create) do |u|
      u.family = Family.find_or_create_by(id: u.family_id)
    end

    trait :father do
      dob 				{ 48.years.ago.to_s }
      gender					'M'
      after(:create) { |u| u.add_role :parent }
    end

    trait :mother do
      dob 				{ 45.years.ago.to_s }
      gender					'F'
      after(:create) { |u| u.add_role :parent }
    end

    trait :child do
      dob 				{ 19.years.ago.to_s }
      gender 				'F'
      after(:create) { |u| u.add_role :child }
    end
  end
end
