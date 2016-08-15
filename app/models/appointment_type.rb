class AppointmentType < ActiveRecord::Base
  has_many :appointments
  belongs_to :user_facing_appointment_type, class_name: "AppointmentType"

  validates :name, :duration, presence: true
  validates_uniqueness_of :name

  WELL_VISIT_TYPES = [9, 21, 41, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]
  WELL_VISIT_TYPE_ATHENA_ID =  11 # map everything else to well visits
  BLOCK_TYPE_ATHENA_IDS = [14, 16] # map both block types

  WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE = {
    0.5 => WELL_VISIT_TYPES[3],
    1 => WELL_VISIT_TYPES[4],
    2 => WELL_VISIT_TYPES[5],
    3 => WELL_VISIT_TYPES[6],
    4 => WELL_VISIT_TYPES[7],
    5 => WELL_VISIT_TYPES[8],
    6 => WELL_VISIT_TYPES[9],
    9 => WELL_VISIT_TYPES[10],
    12 => WELL_VISIT_TYPES[11],
    15 => WELL_VISIT_TYPES[12],
    18 => WELL_VISIT_TYPES[13],
    24 => WELL_VISIT_TYPES[14],
    30 => WELL_VISIT_TYPES[15],
    36 => WELL_VISIT_TYPES[16],
    48 => WELL_VISIT_TYPES[17],
    60 => WELL_VISIT_TYPES[18],
    72 => WELL_VISIT_TYPES[19],
    84 => WELL_VISIT_TYPES[20],
    96 => WELL_VISIT_TYPES[21],
    108 => WELL_VISIT_TYPES[22],
    120 => WELL_VISIT_TYPES[23],
    132 => WELL_VISIT_TYPES[24],
    144 => WELL_VISIT_TYPES[25],
    168 => WELL_VISIT_TYPES[25],
    180 => WELL_VISIT_TYPES[26],
    216 => WELL_VISIT_TYPES[26],
    228 => WELL_VISIT_TYPES[27],
    264 => WELL_VISIT_TYPES[27]
  }

  def self.appointment_type_for_visit_age(patient_age_in_months)
    closest_visit_age_to_exact_age = GenericHelper.closest_item(patient_age_in_months, WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE.keys)
    athena_id = WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[closest_visit_age_to_exact_age]
    AppointmentType.find_by_athena_id(athena_id)
  end

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
