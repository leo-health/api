class MakeAppointmentsProviderNotAUser < ActiveRecord::Migration
  def change
    add_reference :appointments, :provider_sync_profile
    change_column :appointments, :provider_id, :integer, null: true
    change_column :appointments, :booked_by_id, :integer, null: true
    add_column :appointments, :booked_by_type, :string
  end
end
