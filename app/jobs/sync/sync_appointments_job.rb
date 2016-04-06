class SyncAppointmentsJob < SyncJob

  attr_reader :practice

  def initialize(practice)
    super 3.minutes
    @practice = practice
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    super **args.reverse_merge(priority: self.class::HIGH_PRIORITY, owner: practice)
  end

  def self.subscribe(practice, **args)
    new(practice).subscribe **args
  end

  def self.subscribe_if_needed(practice, **args)
    new(practice).subscribe_if_needed practice, **args
  end

  def perform
    practice.get_appointments_from_athena
  end

  def self.queue_name
    'get_appointments'
  end
end
