class CreateProviderSyncProfiles < ActiveRecord::Migration
  def change
    create_table :provider_sync_profiles do |t|
      t.integer :provider_id, null: false
      t.integer :athena_department_id, default: 0
      t.integer :athena_id, default: 0
    end
  end
end
