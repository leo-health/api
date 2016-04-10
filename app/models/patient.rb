class Patient < ActiveRecord::Base
  acts_as_paranoid
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
  belongs_to :sync_job, class_name: Delayed::Job
  belongs_to :vitals_sync_job, class_name: Delayed::Job
  belongs_to :medications_sync_job, class_name: Delayed::Job
  belongs_to :vaccines_sync_job, class_name: Delayed::Job
  belongs_to :allergies_sync_job, class_name: Delayed::Job
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

  after_commit :upgrade_guardian!, :post_to_athena, on: :create

  # subscribe_to_athena only the first time after the patient has been posted to athena
  after_commit :subscribe_to_athena, :if => Proc.new { |record|
    attribute = :athena_id
    record.previous_changes.key?(attribute) &&
    record.previous_changes[attribute].first == 0 &&
    record.previous_changes[attribute].last != 0
  }

  def post_to_athena
    PostPatientJob.new(self).start
  end

  def subscribe_to_athena
    SyncPatientJob.new.subscribe_if_needed self, run_at: Time.now
  end

  def current_avatar
    avatars.order("created_at DESC").first
  end

  private

  def upgrade_guardian!
    family.primary_guardian.try(:upgrade!)
  end
end
