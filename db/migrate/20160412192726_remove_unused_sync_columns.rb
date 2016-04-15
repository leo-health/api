class RemoveUnusedSyncColumns < ActiveRecord::Migration
  def self.up
    drop_table :sync_tasks
    remove_column :delayed_jobs, :cron
    remove_reference :patients, :sync_job, index: true, references: :delayed_jobs
    remove_reference :patients, :vitals_sync_job, index: true, references: :delayed_jobs
    remove_reference :patients, :medications_sync_job, index: true, references: :delayed_jobs
    remove_reference :patients, :vaccines_sync_job, index: true, references: :delayed_jobs
    remove_reference :patients, :allergies_sync_job, index: true, references: :delayed_jobs
    remove_reference :practices, :appointments_sync_job, index: true, references: :delayed_jobs
    remove_reference :provider_sync_profiles, :sync_job, index: true, references: :delayed_jobs
  end

  def self.down
    create_table :sync_tasks
    add_column :delayed_jobs, :cron, :string
    add_reference :patients, :sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :vitals_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :medications_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :vaccines_sync_job, index: true, references: :delayed_jobs
    add_reference :patients, :allergies_sync_job, index: true, references: :delayed_jobs
    add_reference :practices, :appointments_sync_job, index: true, references: :delayed_jobs
    add_reference :provider_sync_profiles, :sync_job, index: true, references: :delayed_jobs
  end
end
