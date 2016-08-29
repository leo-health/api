class PeriodicPollingJob < LeoDelayedJob

  IMMEDIATE_PRIORITY = 0 # Delayed::Job default is 0
  HIGH_PRIORITY = 5
  MEDIUM_PRIORITY = 10
  LOW_PRIORITY = 15

  def initialize(
    interval: nil,
    owner: nil,
    priority: IMMEDIATE_PRIORITY)
    @interval = interval
    @owner = owner
    @priority = priority
  end

  def subscribe(**args)
    if run_at = args[:run_at] || self.try(:schedule_time) || @interval.try(:from_now)
      self.start(**args.reverse_merge(
        run_at: run_at,
        owner: @owner,
        priority: @priority
      ))
    end
  end

  def subscribe_if_needed(**args)
    Delayed::Job.find_by(
      owner: @owner,
      queue: self.queue_name
    ) || subscribe(**args) # subclass implementation
  end

  def success(completed_job)
    subscribe
  end
end
