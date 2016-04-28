class Slot < ActiveRecord::Base
  include Syncable

  belongs_to :provider_sync_profile
  belongs_to :appointment_type
  belongs_to :appointment
  scope :free, -> { where(free_busy_type: :free) }

  def self.between(start_datetime, end_datetime)
    where("start_datetime >= ? AND end_datetime <= ?", start_datetime, end_datetime)
  end

  def duration
    (end_datetime - start_datetime) / 60
  end
end
