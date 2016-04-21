
# TODO: REFACTOR: Should be named PeriodicPollingJob
class PeriodicPollingJob < LeoDelayedJob

  IMMEDIATE_PRIORITY = 0 # Delayed::Job default is 0
  HIGH_PRIORITY = 5
  MEDIUM_PRIORITY = 10
  LOW_PRIORITY = 15

  def initialize(interval: 0, owner: nil, priority: IMMEDIATE_PRIORITY)
    @interval = interval
    @owner = owner
    @priority = priority
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    self.start(**args.reverse_merge(run_at: @interval.from_now, owner: @owner, priority: @priority))
  end

  def subscribe_if_needed(**args)
    Delayed::Job.find_by(owner: @owner, queue: self.queue_name) || subscribe(**args) # subclass implementation
  end

  def success(completed_job)
    subscribe
  end
end
