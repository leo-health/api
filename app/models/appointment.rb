class Appointment < ActiveRecord::Base

	MAX_DURARTION = 40
	MIN_DURARTION = 10

	
	def self.for_user(user)
		if user.has_role? :parent
			Appointment.all
		elsif user.has_role? :guardian
			#TODO: Implement
		elsif user.has_role? :child
			#TODO: Implement
		elsif user.has_role? :physician
			#TODO: Implement
		elsif user.has_role? :clinical_staff
			#TODO: Implement
		elsif user.has_role? :other_staff
			#TODO: Implement
		elsif user.has_role? :admin
			#TODO: Implement
		end
	end
end
