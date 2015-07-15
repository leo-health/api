class RenamePatientToHealthRecord < ActiveRecord::Migration
  def change
    rename_table :patients, :health_records
  end
end
