class MilestoneContentJob < PeriodicPollingJob
  def initialize(patient:, milestone_content:)

    @patient = patient
    @milestone_content = milestone_content

    super(
      owner: patient,
      priority: self.class::MEDIUM_PRIORITY,
      scheduler_proc: method(:schedule_time)
    )
  end

  def schedule_time
    return nil unless @milestone_content
    @patient.birth_date + @milestone_content
      .age_of_patient_in_months
      .months
  end

  def next_milestone_content
    ages = LinkPreview::AGES_FOR_MILESTONE_CONTENT
    next_age = if @milestone_content
      ages[ages.index(@milestone_content.age_of_patient_in_months) + 1]
    else
      ages.first
    end

    LinkPreview.where(
      age_of_patient_in_months: next_age,
      category: :milestone_content
    ).first
  end

  def perform
    if @milestone_content
      UserLinkPreview.where(
        link_preview: @milestone_content,
        owner: @patient
      ).destroy_all
    end

    @milestone_content = next_milestone_content

    @patient.family.guardians.each do |guardian|
      UserLinkPreview.create(
        link_preview: @milestone_content,
        owner: @patient,
        user: guardian
      )
    end
  end

  def self.queue_name
    'send_milestone_link_preview'
  end
end
