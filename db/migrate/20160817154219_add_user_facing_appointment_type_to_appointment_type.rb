class AddUserFacingAppointmentTypeToAppointmentType < ActiveRecord::Migration
  def change
    add_column :appointment_types, :user_facing_appointment_type_id, :integer
  end
end
