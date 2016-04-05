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

  # ????: can this code be a Patient monkey patch to avoid fat classes? what is the right architecture? protocol?
  def subscribe_to_athena

    # model objects should handle fetching and syncing themselves
    # need to find a way to abstract away common things like priority and cron

    # props = [nil, :vitals, :medications, :vaccines, :allergies]
    # props.each { |prop|
    #   # ????: how to avoid copy and paste below?
    # }

    opts = { cron: "*/5 * * * * *", priority: 10 }
    updates = {}
    updates.merge!(sync_job_id: delay(queue: "get_patient", **opts).get_from_athena.id) if !sync_job
    updates.merge!(vitals_sync_job_id: delay(queue: "get_patient_vitals", **opts).get_vitals_from_athena.id) if !vitals_sync_job
    updates.merge!(medications_sync_job_id: delay(queue: "get_patient_medications", **opts).get_medications_from_athena.id) if !medications_sync_job
    updates.merge!(vaccines_sync_job_id: delay(queue: "get_patient_vaccines", **opts).get_vaccines_from_athena.id) if !vaccines_sync_job
    updates.merge!(allergies_sync_job_id: delay(queue: "get_patient_allergies", **opts).get_allergies_from_athena.id) if !allergies_sync_job
    # Rails bug https://github.com/rails/rails/issues/14493
    # cannot save or update the record in an on: :create callback. Apparently update_columns works though
    update_columns(updates)
  end

  def post_to_athena
    # TODO: refacor: what is the correct place for this api logic?
    SyncServiceHelper::Syncer.new.sync_leo_patient self
  end

  def put_to_athena
    # TODO: refactor: we may want to use different methods for post_to_athena vs put_to_athena, rather than if branching
    raise "method not yet implemented!"
  end

  def get_from_athena
    # TODO: fill with get patient api call
  end

  def get_vitals_from_athena
    SyncServiceHelper::Syncer.new.sync_vitals self
  end

  def get_medications_from_athena
    SyncServiceHelper::Syncer.new.sync_medications self
  end

  def get_vaccines_from_athena
    SyncServiceHelper::Syncer.new.sync_vaccines self
  end

  def get_allergies_from_athena
    SyncServiceHelper::Syncer.new.sync_allergies self
  end

  private

  def upgrade_guardian!
    family.primary_guardian.try(:upgrade!)
  end
end
