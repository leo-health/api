class CreateAllergies < ActiveRecord::Migration
  def change
    create_table :allergies do |t|
      t.belongs_to :patient, index: true

      t.integer :athena_id, index: true, default: 0, null: false #allergenid
      t.string :allergen, default: '', null: false #allergenname
      t.datetime :onset_at #onsetdate

      t.timestamps null: false

      """
  note  string  Note about this allergy
  deactivatedate  date  Date of allergy deactivation. Set to deactivate the allergy
  onsetdate date  Date of allergy onset
  reactions string  List of documented reactions
    
  severity  string  Severity of the reaction
  severitysnomedcode  integer SNOMED code for the severity of this reaction
  snomedcode  integer SNOMED code for this reaction
  reactionname  string  Name of the reaction
  allergenname  string  The name of the allergen.
  allergenid  integer Athena ID for this allergen.
"""
    end
  end
end
