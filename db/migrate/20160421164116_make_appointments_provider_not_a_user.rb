class MakeAppointmentsProviderNotAUser < ActiveRecord::Migration
  def change
    change_column_null :appointments, :provider_id, true
    change_column_null :appointments, :booked_by_id, true
    add_column :appointments, :booked_by_type, :string
  end
  
  def down
    change_column_null :appointments, :provider_id, true
    change_column_null :appointments, :booked_by_id, true
  end
end
