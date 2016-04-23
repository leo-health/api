class AddSyncStatusToPatient < ActiveRecord::Migration
  def change
    create_table :sync_statuses do |t|
      t.boolean :should_attempt_sync, default: true
      t.belongs_to :owner, polymorphic: true, index: true
    end
    add_reference :patients, :sync_status
  end
end
