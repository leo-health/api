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

FactoryGirl.define do
  sequence :email do |n|
  "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Naiyan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    dob 				{ 29.years.ago.to_s }
    sex					'M'
    email
    password    'fake_pass'
    password_confirmation    'fake_pass'
    family_id    11
    association :family, factory: :family

    after(:create) do |u|
      u.family = Family.find_or_create_by(id: u.family_id)
    end

    trait :father do
      first_name 	'Phil'
      last_name		'Dunphy'
      dob 				{ 48.years.ago.to_s }
      sex					'M'
      email				'phil.dunphy@gmail.com'
      after(:create) { |u| u.add_role :parent }
    end

    trait :mother do
      first_name	'Claire'
      last_name		'Dunphy'
      dob 				{ 45.years.ago.to_s }
      sex					'F'
      email 			'claire.dunphy@gmail.com'
      after(:create) { |u| u.add_role :parent }
    end

    trait :first_child do
      first_name 	'Haley'
      last_name		'Dunphy'
      dob 				{ 19.years.ago.to_s }
      sex 				'F'
      email 			'haley.dunphy@gmail.com'
      after(:create) { |u| u.add_role :child }
    end

    trait :middle_child do
      first_name 	'Alex'
      last_name		'Dunphy'
      dob 				{ 17.years.ago.to_s }
      sex 				'F'
      email 			'alex.dunphy@gmail.com'
      after(:create) { |u| u.add_role :child }
    end

    trait :last_child do
      first_name	'Luke'
      last_name 	'Dunphy'
      dob 				{ 15.years.ago.to_s }
      sex 				'F'
      email 			'luke.dunphy@gmail.com'
      # family
      after(:create) { |u| u.add_role :child }
    end
  end
end
