class PostAppointmentJob < LeoDelayedJob
  attr_reader :appointment

  def initialize(appointment)
    @appointment = appointment
  end

  def start
    super(owner: @appointment)
  end

  def perform
    AthenaAppointmentSyncService.new.post_appointment @appointment
  end

  def self.queue_name
    'post_appointment'
  end
end
