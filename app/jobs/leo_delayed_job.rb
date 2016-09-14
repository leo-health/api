class LeoDelayedJob
  def start(**args)
    Delayed::Job.enqueue self, **args.reverse_merge(run_at: Time.now)
  end

  def queue_name
    self.class.try :queue_name
  end
end
