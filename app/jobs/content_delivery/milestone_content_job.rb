class MilestoneContentJob < PeriodicPollingJob
  def initialize(patient:)
    super(
      owner: patient,
      priority: self.class::MEDIUM_PRIORITY
    )
  end

  def schedule_time
    @owner.time_of_next_milestone.try(:+, 11.hours)
  end

  def perform
    @owner.ensure_current_milestone_link_preview
  end

  def self.queue_name
    'send_milestone_link_preview'
  end
end
