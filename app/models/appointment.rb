# == Schema Information
#
# Table name: appointments
#
#  id                         :integer          not null, primary key
#  appointment_status         :string           default("o"), not null
#  athena_appointment_type    :string
#  leo_provider_id            :integer          not null
#  athena_provider_id         :integer          default(0), not null
#  leo_patient_id             :integer          not null
#  athena_patient_id          :integer          default(0), not null
#  booked_by_user_id          :integer          not null
#  rescheduled_appointment_id :integer
#  duration                   :integer          not null
#  appointment_date           :date             not null
#  appointment_start_time     :time             not null
#  frozenyn                   :boolean
#  leo_appointment_type       :string
#  athena_appointment_type_id :integer          default(0), not null
#  family_id                  :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  athena_id                  :integer          default(0), not null
#  athena_department_id       :integer          default(0), not null
#

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
