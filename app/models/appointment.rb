class Appointment < ActiveRecord::Base

	def for_user(user)
		if user.has_role :parent
		elsif user.has_role :guardian
			#TODO: Implement
		elsif user.has_role :child
			#TODO: Implement
		elsif user.has_role :physician
			#TODO: Implement
		elsif user.has_role :clinical_staff
			#TODO: Implement
		elsif user.has_role :other_staff
			#TODO: Implement
		elsif user.has_role :admin
			#TODO: Implement
		end
	end
end
