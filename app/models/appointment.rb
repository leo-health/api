class Appointment < ActiveRecord::Base
  belongs_to :leo_patient, class_name: "User"

  #helpers for booked status
  def pre_checked_in?
    return future? || open? || cancelled?
  end

  def post_checked_in?
    return !pre_checked_in?
  end

  def booked?
    return future? || checked_in? || checked_out? || charge_entered?
  end

  def cancelled?
    return appointment_status == "x"
  end

  def future?
    return appointment_status == "f"
  end

  def open?
    return appointment_status == "o"
  end

  def checked_in?
    return appointment_status == "2"
  end

  def checked_out?
    return appointment_status == "3"
  end

  def charge_entered?
    return appointment_status == "4"
  end

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
		if user.has_role? :guardian
			Appointment.for_family(user.family)
		elsif user.has_role? :patient
			#TODO: Implement
		elsif user.has_role? :clinical
			#TODO: Implement
		elsif user.has_role? :clinical_support
			#TODO: Implement
		elsif user.has_role? :super_user
			Appointment.all
		end
	end
end
