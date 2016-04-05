class AddSyncDelayedJobToModels < ActiveRecord::Migration
  def change
    add_reference :patients, :sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :vitals_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :medications_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :vaccines_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :allergies_sync_job, index: true, references: :delayed_jobs
    add_reference :practices, :appointments_sync_job, index: true, references: :delayed_jobs
    add_reference :provider_sync_profiles, :sync_job, index: true, references: :delayed_jobs
  end
end
