class ChangeAppointmentTypes < ActiveRecord::Migration
  def change
    remove_column :appointment_types, :description, :string
    add_column :appointment_types, :short_description, :string
    add_column :appointment_types, :long_description, :string
    add_column :appointment_types, :name, :string, null: false
  end
end
