class SyncJob

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
    Delayed::Job.enqueue self, args.reverse_merge(run_at: interval.from_now)
  end

  def subscribe_if_needed(owner, **args)
    unless Delayed::Job.exists? owner: owner, queue: queue_name
      subscribe args.reverse_merge(owner: owner)
    end
  end

  def success(completed_job)
    subscribe
  end

  def queue_name
    @class.try :queue_name
  end
end
