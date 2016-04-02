class SyncRemoteAppointmentsJob

  attr_accessor :patient

  def initialize(patient)
    @patient = patient
  end

  def self.enqueue_with_family(family, run_at=Time.now)
    byebug
    family.patients.find_each do |patient|
      Delayed::Job.enqueue self.new(patient) run_at: run_at
    end
  end

  def self.enqueue_with_practice(practice, run_at=Time.now)
    SyncServiceHelper::Syncer.new
    .delay(run_at: run_at)
    .sync_athena_appointments({
      departmentid: practice.athena_id,
      startdate: Date.today.strftime("%m/%d/%Y"),
      enddate: 1.year.from_now.strftime("%m/%d/%Y"),
      })
  end

  def perform
    SyncServiceHelper::Syncer.new.sync_athena_appointments({
      departmentid: patient.family.primary_guardian.practice.athena_id,
      startdate: Date.today.strftime("%m/%d/%Y"),
      enddate: 1.year.from_now.strftime("%m/%d/%Y"),
      patientid: patient.athena_id
      })
  end

  def queue_name
    'sync_service'
  end
end
