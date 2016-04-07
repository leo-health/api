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

  after_commit :upgrade_guardian!, :subscribe_to_athena, on: :create

  def current_avatar
    avatars.order("created_at DESC").first
  end

  def subscribe_to_athena
    SyncPatientJob.subscribe_if_needed self, run_at: Time.now
  end

  def post_to_athena
    # TODO: refacor: what is the correct place for this api logic?
    SyncServiceHelper::Syncer.instance.sync_leo_patient self
  end

  def put_to_athena
    # TODO: refactor: we may want to use different methods for post_to_athena vs put_to_athena, rather than if branching
    raise "method not yet implemented!"
  end

  def get_from_athena
    # TODO: fill with get patient api call
  end

  def get_vitals_from_athena
    SyncServiceHelper::Syncer.instance.sync_vitals self
  end

  def get_medications_from_athena
    SyncServiceHelper::Syncer.instance.sync_medications self
  end

  def get_vaccines_from_athena
    SyncServiceHelper::Syncer.instance.sync_vaccines self
  end

  def get_allergies_from_athena
    SyncServiceHelper::Syncer.instance.sync_allergies self
  end

  private

  def upgrade_guardian!
    family.primary_guardian.try(:upgrade!)
  end
end
