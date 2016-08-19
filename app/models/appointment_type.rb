class AppointmentType < ActiveRecord::Base
  has_many :appointments
  belongs_to :user_facing_appointment_type, class_name: "AppointmentType"

  validates :name, :duration, presence: true
  validates_uniqueness_of :name

  WELL_VISIT_TYPES = [9, 21, 41, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]
  WELL_VISIT_TYPE_ATHENA_ID =  11 # map everything else to well visits
  BLOCK_TYPE_ATHENA_IDS = [14, 16] # map both block types

  def self.blocked
    find_by(athena_id: BLOCK_TYPE_ATHENA_IDS)
  end

  def self.other
    find_by(name: "Other")
  end

  def self.APPOINTMENT_TYPE_MAP
    Hash[AppointmentType.where(hidden: false).order(:athena_id).map { |e| [e.athena_id]*2 }]
    .reverse_merge(Hash[WELL_VISIT_TYPES.map { |e| [e, WELL_VISIT_TYPE_ATHENA_ID] }])
  end

  def self.user_facing_appointment_type_for_athena_id(athena_id)
    # try the given type
    appt_type = find_by(
      hidden: false,
      athena_id: athena_id)
    # try to map the type
    appt_type ||= find_by(
      hidden: false,
      athena_id: self.APPOINTMENT_TYPE_MAP[athena_id])
    # default to "Other"
    appt_type ||= other
  end
end
