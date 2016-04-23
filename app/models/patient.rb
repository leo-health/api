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

  after_commit :upgrade_guardian!, on: :create
  after_commit :post_to_athena, if: -> { sync_status.should_attempt_sync && athena_id == 0 }

  # subscribe_to_athena only the first time after the patient has been posted to athena
  after_commit :subscribe_to_athena, if: Proc.new { |record|
    attribute = :athena_id
    record.previous_changes.key?(attribute) &&
    record.previous_changes[attribute].first == 0 &&
    record.previous_changes[attribute].last != 0
  }

  def post_to_athena
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

  private

  def sync_status_with_auto_create
    update(sync_status: SyncStatus.create!(owner: self)) unless sync_status_without_auto_create
    sync_status_without_auto_create
  end
  alias_method_chain :sync_status, :auto_create

  def upgrade_guardian!
    family.primary_guardian.try(:upgrade!)
  end
end
