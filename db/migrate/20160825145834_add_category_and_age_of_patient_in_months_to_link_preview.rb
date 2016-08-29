class AddCategoryAndAgeOfPatientInMonthsToLinkPreview < ActiveRecord::Migration
  def change
    add_column :link_previews, :category, :string
    add_column :link_previews, :age_of_patient_in_months, :float
  end
end
