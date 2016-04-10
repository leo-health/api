class SyncAppointmentsJob < PeriodicPollingJob

  attr_reader :practice

  def initialize
    super 5.minutes
    @service = AthenaAppointmentSyncService.new
  end

  def subscribe(practice, **args)
    @practice = practice
    super(**args.reverse_merge(priority: self.class::HIGH_PRIORITY, owner: @practice))
  end

  def perform
    @service.sync_appointments_for_practice @practice
  end

  def self.queue_name
    'get_appointments'
  end
end
