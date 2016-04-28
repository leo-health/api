class AddAppointmentToSlots < ActiveRecord::Migration
  def change
    add_reference :slots, :appointment
  end
end
