
# TODO: REFACTOR: Should be named PeriodicPollingJob
class PeriodicPollingJob < LeoDelayedJob

  IMMEDIATE_PRIORITY = 0 # Delayed::Job default is 0
  HIGH_PRIORITY = 5
  MEDIUM_PRIORITY = 10
  LOW_PRIORITY = 15

  attr_reader :interval

  def initialize(interval)
    @interval = interval || 0
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    self.start(**args.reverse_merge(run_at: interval.from_now))
  end

  def subscribe_if_needed(owner, **args)
    unless Delayed::Job.exists? owner: owner, queue: self.queue_name
      subscribe owner, **args # subclass implementation. this should be a protocol
    end
  end

  def success(completed_job)
    subscribe
  end
end
