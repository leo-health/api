class Patient < ActiveRecord::Base
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

  def last_milestone_link
    ages = LinkPreview::AGES_FOR_MILESTONE_CONTENT
    age = age_in_months

    closest_milestone_age = GenericHelper.closest_item(age, ages)
    i = ages.index(closest_milestone_age) #closest milestone
    i -= closest_milestone_age > age ? 2 : 1 # last milestone
    return nil if i < 0 # haven't yet reached a milestone

    LinkPreview.where(
      age_of_patient_in_months: ages[i],
      category: :milestone_content
    ).first
  end

  def enqueue_milestone_content_delivery_job
    MilestoneContentJob.new(
      patient: self,
      milestone_content: last_milestone_link
    ).subscribe_if_needed(run_at: Time.now)
  end

  def current_avatar
    avatars.order("created_at DESC").first
  end

  # Modified from original solution: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
  def age_in_months
    dob = birth_date
    now = Time.zone.now.to_date
    months = now.month - dob.month - ((now.day >= dob.day) ? 0 : 1)
    years = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    years * 12 + months
  end
end
