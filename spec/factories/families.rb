require 'stripe_mock'

FactoryGirl.define do
	factory :family do
		trait :member do
			after(:create) do |instance|
				instance.update_or_create_stripe_subscription_if_needed! StripeMock.create_test_helper.generate_card_token
			end
		end
		factory :family_with_members do
			after(:create) do |instance|
				create(:user, :guardian, family: instance)
				secondary_guardian = create(:user, :guardian, family: instance)
				secondary_guardian.confirm_secondary_guardian
				create(:patient, family: instance)
				create(:patient, family: instance)
				create(:patient, family: instance)
				instance.reload
			end
		end
	end
end
