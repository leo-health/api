class PostAppointmentJob < LeoDelayedJob
  attr_reader :appointment

  def initialize(appointment)
    @appointment = appointment
    @service = AthenaAppointmentSyncService.new
  end

  def start
    super(owner: @appointment)
  end

  def perform
    @service.post_appointment @appointment
  end

  def self.queue_name
    'post_appointment'
  end
end
