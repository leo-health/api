class AppointmentType < ActiveRecord::Base
  has_many :appointments
  validates :name, :duration, :athena_id, presence: true
  validates_uniqueness_of :name

  # TODO: remove hard coded ids
  WELL_VISIT_TYPES = Rails.env.production? ? [9, 21, 41, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105] : [9, 21, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 82, 62, 63, 64, 65, 66]
  WELL_VISIT_TYPE_ATHENA_ID =  11 # map everything else to well visits
  BLOCK_TYPE_ATHENA_ID = 14 # map both block types

  def self.blocked
    find_by(athena_id: BLOCK_TYPE_ATHENA_ID)
  end

  def self.APPOINTMENT_TYPE_MAP
    { 61 => BLOCK_TYPE_ATHENA_ID }.reverse_merge(Hash[AppointmentType.order(:athena_id).map { |e| [e.athena_id]*2 }].reverse_merge(Hash[WELL_VISIT_TYPES.map { |e| [e, WELL_VISIT_TYPE_ATHENA_ID] }]))
  end

  def self.mapped_appointment_type_id_for_athena_id(appointmenttypeid)
    self.APPOINTMENT_TYPE_MAP[appointmenttypeid] || BLOCK_TYPE_ATHENA_ID
  end
end
