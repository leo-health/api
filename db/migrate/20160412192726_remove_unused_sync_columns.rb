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
    create_table "sync_tasks", force: :cascade do |t|
      t.integer  "sync_id",     default: 0,     null: false
      t.string   "sync_type",   default: "",    null: false
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
      t.string   "sync_params", default: "",    null: false
      t.integer  "num_failed",  default: 0,     null: false
      t.boolean  "working",     default: false, null: false
    end

    add_index "sync_tasks", ["num_failed"], name: "index_sync_tasks_on_num_failed", using: :btree
    add_index "sync_tasks", ["sync_id"], name: "index_sync_tasks_on_sync_id", using: :btree
    add_index "sync_tasks", ["sync_type"], name: "index_sync_tasks_on_sync_type", using: :btree
    add_index "sync_tasks", ["working"], name: "index_sync_tasks_on_working", using: :btree
    
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
