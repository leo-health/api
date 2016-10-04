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

  has_many :appointments, -> { Appointment.booked }, dependent: :nullify
  has_many :medications, dependent: :destroy
  has_many :allergies, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :vaccines, dependent: :destroy
  has_many :vitals, dependent: :destroy
  has_many :insurances, dependent: :destroy
  has_many :avatars, as: :owner, dependent: :destroy
  has_many :user_generated_health_records, dependent: :destroy
  has_many :forms, dependent: :destroy

  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
  validates :athena_id, presence: true, if: Proc.new { |patient| patient.athena_id > 0 }
  after_commit :post_to_athena, if: -> { sync_status.should_attempt_sync && athena_id == 0 }
  # subscribe_to_athena only the first time after the patient has been posted to athena
  after_commit :subscribe_to_athena, if: :did_successfully_sync?
  after_commit :enqueue_milestone_content_delivery_job, on: :create


  # Getters

  def current_avatar
    avatars.order("created_at DESC").first
  end


  # Sync

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


  # Milestone Content

  def enqueue_milestone_content_delivery_job
    if ENV['FEATURE_FLAG_MILESTONE_CONTENT']
      MilestoneContentJob.new(patient: self).subscribe_if_needed(run_at: Time.now)
    end
  end

  def ensure_current_milestone_link_preview
    # do nothing if the patient hasn't hit a milestone yet
    return nil unless index = LinkPreview.milestone_index_for_age(age_in_months)

    # only send push notification when the milestone changes - not the initial one
    sends_push_notification_on_publish = false

    # destroy out of date UserLinkPreviews
    # case when the patient has no more milestones is handled by the fact that current_age == nil if index out of bounds
    current_age = LinkPreview.ages_for_milestone_content[index]
    UserLinkPreview.where(owner: self).find_each do |user_link_preview|
      link_is_milestone_content = user_link_preview.link_preview.category.to_sym == :milestone_content
      link_is_out_of_date = user_link_preview.link_preview.age_of_patient_in_months != current_age

      if link_is_milestone_content && link_is_out_of_date
        user_link_preview.destroy
        sends_push_notification_on_publish = true
      end
    end

    # find or create up to date UserLinkPreviews
    LinkPreview.milestone_content_for_age(current_age).each do |link_preview|
      last_milestone_date = birth_date + link_preview.age_of_patient_in_months.months
      if last_milestone_date + 30.days > Date.today
        family.guardians.each do |guardian|
          UserLinkPreview.create_with(
            sends_push_notification_on_publish: sends_push_notification_on_publish
          ).find_or_create_by(
            link_preview: link_preview,
            owner: self,
            user: guardian
          )
        end
      end
    end
  end

  def time_of_next_milestone
    current_milestone_index = LinkPreview.milestone_index_for_age(age_in_months)
    current_milestone_index ||= 0
    return nil unless next_milestone_age = LinkPreview.ages_for_milestone_content[
      current_milestone_index + 1
    ]
    birth_date + next_milestone_age.months
  end

  # Modified from original solution: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
  def age_in_months
    dob = birth_date
    now = Time.zone.now.to_date
    months = now.month - dob.month - ((now.day >= dob.day) ? 0 : 1)
    years = now.year - dob.year
    years * 12 + months
  end
end
