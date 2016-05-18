class Slot < ActiveRecord::Base
  include Syncable

  belongs_to :provider
  belongs_to :appointment_type
  belongs_to :appointment
  scope :free, -> { where(free_busy_type: :free) }

  def self.start_datetime_between(start_datetime, end_datetime)
    return unless start_datetime || end_datetime
    if !start_datetime
      where("start_datetime <= ?", end_datetime)
    elsif !end_datetime
      where("start_datetime >= ?", start_datetime)
    else
      where("start_datetime >= ? AND start_datetime <= ?", start_datetime, end_datetime)
    end
  end

  def duration
    (end_datetime - start_datetime) / 60
  end
end
