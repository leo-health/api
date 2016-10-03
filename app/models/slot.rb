class Slot < ActiveRecord::Base
  include Syncable
  include StartDateTimeBetween

  belongs_to :provider
  belongs_to :appointment_type
  belongs_to :appointment
  validates_uniqueness_of :athena_id
  scope :free, -> { where(free_busy_type: :free) }

  def duration
    (end_datetime - start_datetime) / 60
  end
end
