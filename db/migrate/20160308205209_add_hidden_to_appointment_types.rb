class AddHiddenToAppointmentTypes < ActiveRecord::Migration
  def change
    add_column :appointment_types, :hidden, :boolean, default: false
  end
end
