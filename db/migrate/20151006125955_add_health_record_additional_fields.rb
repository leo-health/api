class AddHealthRecordAdditionalFields < ActiveRecord::Migration
  def up
    add_column :allergies, :severity, :string, null: false, default: ""
    add_column :allergies, :note, :string, null: false, default: ""

    add_column :medications, :dose, :string, null: false, default: ""
    add_column :medications, :route, :string, null: false, default: ""
    add_column :medications, :frequency, :string, null: false, default: ""
    remove_column :medications, :patient_note
    add_column :medications, :note, :string, null: false, default: ""
  end

  def down
    remove_column :allergies, :severity
    remove_column :allergies, :note

    remove_column :medications, :dose
    remove_column :medications, :route
    remove_column :medications, :frequency
    add_column :medications, :patient_note, :string, null: false, default: ""
    remove_column :medications, :note
  end
end
