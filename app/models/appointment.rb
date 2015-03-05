# == Schema Information
#
# Table name: appointments
#
#  id                         :integer          not null, primary key
#  appointment_status         :string
#  athena_appointment_type    :string
#  leo_provider_id            :integer          not null
#  athena_provider_id         :integer
#  leo_patient_id             :integer          not null
#  athena_patient_id          :integer
#  booked_by_user_id          :integer          not null
#  rescheduled_appointment_id :integer
#  duration                   :integer          not null
#  appointment_date           :date             not null
#  appointment_start_time     :time             not null
#  frozenyn                   :boolean
#  leo_appointment_type       :string
#  athena_appointment_type_id :integer
#  family_id                  :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Appointment < ActiveRecord::Base

	def self.MAX_DURATION
		40
	end
	def self.MIN_DURATION
		10
	end

	
	
	def self.for_family(family)
		Appointment.where(family_id: family.id)
	end

	def self.for_user(user)
		if user.has_role? :parent
			Appointment.for_family(user.family)
		elsif user.has_role? :guardian
			Appointment.for_family(user.family)
		elsif user.has_role? :child
			#TODO: Implement
		elsif user.has_role? :physician
			#TODO: Implement
		elsif user.has_role? :clinical_staff
			#TODO: Implement
		elsif user.has_role? :other_staff
			#TODO: Implement
		elsif user.has_role? :admin
			Appointment.all
		end
	end
end
