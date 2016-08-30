class Patient < ActiveRecord::Base
  include ActionView::Helpers
  acts_as_paranoid
  include Syncable
  include PgSearch
  pg_search_scope(
    :search,
    against: %i( first_name last_name ),
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.3 }
    }
  )

  belongs_to :family
  has_many :appointments, -> { Appointment.booked }
  has_many :medications
  has_many :allergies
  has_many :photos
  has_many :vaccines
  has_many :vitals
  has_many :insurances
  has_many :avatars, as: :owner
  has_many :user_generated_health_records
  has_many :forms

  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
  after_commit :post_to_athena, if: -> { sync_status.should_attempt_sync && athena_id == 0 }
  # subscribe_to_athena only the first time after the patient has been posted to athena
  after_commit :subscribe_to_athena, if: :did_successfully_sync?
  after_commit :enqueue_milestone_content_delivery_job, on: :create

  def did_successfully_sync?
    attribute = :athena_id
    self.previous_changes.key?(attribute) &&
    self.previous_changes[attribute].first == 0 &&
    self.previous_changes[attribute].last != 0
  end

  def post_to_athena
    return if family.incomplete?
    PostPatientJob.new(self).start unless Delayed::Job.find_by(owner: self, queue: PostPatientJob.queue_name)
  end

  def subscribe_to_athena
    if athena_id == 0
      post_to_athena
    else
      SyncPatientJob.new(self).subscribe_if_needed run_at: Time.now
    end
  end

  def current_avatar
    avatars.order("created_at DESC").first
  end

  # Modified from original solution: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
  def age_in_months
    dob = birth_date
    now = Time.zone.now.to_date
    months = now.month - dob.month - ((now.day >= dob.day) ? 0 : 1)
    years = now.year - dob.year
    years * 12 + months
  end

  def enqueue_milestone_content_delivery_job
    MilestoneContentJob.new(patient: self).subscribe_if_needed(run_at: Time.now)
  end

  def time_of_next_milestone
    current_milestone_index = LinkPreview.current_milestone_index_for_age(age_in_months)
    current_milestone_index ||= 0
    return nil unless next_milestone_age = LinkPreview.ages_for_milestone_content[
      current_milestone_index + 1
    ]
    birth_date + next_milestone_age.months
  end

  def current_milestone_age_index
    LinkPreview.current_milestone_index_for_age(age_in_months)
  end

  def ensure_current_milestone_link_preview
    # do nothing if the patient hasn't hit a milestone yet
    return nil unless index = current_milestone_age_index

    # destroy out of date UserLinkPreviews
    # case when no more milestones is handled by current_age = nil if index out of bounds
    current_age = LinkPreview.ages_for_milestone_content[index]
    UserLinkPreview.where(
      owner: self
    ).find_each do |ulp|
      if ulp.link_preview.category.to_sym == :milestone_content
        ulp.destroy unless ulp.link_preview.age_of_patient_in_months == current_age
      end
    end

    # find or create current UserLinkPreviews
    LinkPreview.milestone_content_for_age(current_age).each do |lp|
      family.guardians.each do |guardian|
        UserLinkPreview.find_or_create_by(
          link_preview: lp,
          owner: self,
          user: guardian
        )
      end
    end
  end
end
