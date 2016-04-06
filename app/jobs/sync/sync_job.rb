class SyncJob
  attr_accessor :delayed_job, :interval
  def initialize(interval)
    @interval = interval || 0
  end

  def subscribe_if_needed(owner, **args)
    unless Delayed::Job.exists? owner: owner, queue: queue_name
      subscribe args.reverse_merge(owner: owner)
    end
  end

  def subscribe(**args)
    @delayed_job = Delayed::Job.enqueue self, args.reverse_merge(run_at: interval.from_now)
  end

  def success(completed_job)
    subscribe
  end

  def queue_name
    @class.try :queue_name
  end
end
