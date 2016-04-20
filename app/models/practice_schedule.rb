class PracticeSchedule < ActiveRecord::Base
  include Schedule
  belongs_to :practice
  before_save :ensure_single_active_schedule

  validates_presence_of :practice, :schedule_type, :monday_start_time, :monday_end_time,
                        :tuesday_start_time, :tuesday_end_time, :wednesday_start_time, :wednesday_end_time,
                        :thursday_start_time, :thursday_end_time, :friday_start_time, :friday_end_time,
                        :saturday_start_time, :saturday_end_time, :sunday_start_time, :sunday_end_time

  private

  def ensure_single_active_schedule
    self.class.where('id != ? and active', self.id).update_all("active = 'false'") if self.active
  end
end
