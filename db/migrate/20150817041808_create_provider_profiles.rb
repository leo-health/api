class CreateProviderProfiles < ActiveRecord::Migration
  def change
    create_table :provider_profiles do |t|
      t.integer :provider_id, null: false
      t.string :specialties, array: true
      t.string :credentials, array: true
      t.timestamps null: false
    end
    add_index :provider_profiles, :provider_id, unique: true
  end
end
