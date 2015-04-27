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
	# callbacks for generating sync tasks
  # if a sync task cannot be created, the transaction will be rolled back.
  attr_accessor :skip_sync_callbacks
  after_save :create_update_from_leo_sync_task, on: [:create, :update], unless: :skip_sync_callbacks
  after_destroy :create_update_from_athena_sync_task, on: :destroy, unless: :skip_sync_callbacks

  #create a sync task for the Appointment that is being updated
  def create_update_from_leo_sync_task
    SyncTask.create!(sync_source: :leo, sync_type: :appointment, sync_id: self.id)
  end

  #create a sync task for the Appointment that is being deleted
  def create_update_from_athena_sync_task
    SyncTask.create!(sync_source: :athena, sync_type: :appointment, sync_id: self.athena_id) unless self.athena_id == 0
  end

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
