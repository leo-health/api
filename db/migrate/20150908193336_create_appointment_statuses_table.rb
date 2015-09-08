class CreateAppointmentStatusesTable < ActiveRecord::Migration
  def change
    create_table :appointment_statuses do |t|
      t.string :description
      t.string :status
    end
  end
end
