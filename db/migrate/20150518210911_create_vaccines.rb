class CreateVaccines < ActiveRecord::Migration
  def change
    create_table :vaccines do |t|
      t.belongs_to :patient, index: true

      t.string :athena_id, index: true, default: 0, null: false #vaccineid
      t.string :vaccine, default: '', null: false #description
      t.datetime :administered_at #administerdate
      

      #filter status == ADMINISTERED

      t.timestamps null: false
"""
cvx integer Vaccine Administered Code
description string  Vaccine description
mvx integer Manufacturer code
vaccineid string  Athena ID for this vaccine (prefix of H for historical, C for clinical)
vaccinetype string  Type of vaccine (either CLINICAL - ordered/administered by the practice, or HISTORICAL - from patient's previous medical history or alternative source)
status  string  Status of this vaccine (one of: ADMINISTERED, REFUSED, PRESCRIBED but not adminstered yet)
administerdate  date  Date when this vaccine was administered (if administered)
administernote  string  Note associated with administering the vaccine, if available
refuseddate date  Date when this vaccine was refused (if refused)
refusedreason string  Reason for refusal, if available
refusednote string  Note associated with refusal, if available
prescribeddate  date  Date when this vaccine was prescribed (if prescribed)
expirationdate  date  Date to administer vaccine by
administersite  string  Site where the vaccine was administered
administerroute string  Route by which this vaccine was administered
vaccinator  string  Individual who has administered the vaccine
amount  number  Quantity of the vaccine that was adminsitered
units string  Units corresponding to the above quantity
deleteddate date  Date when this vaccine was deleted (if deleted)
approveddate  date  Date when this vaccine order was approved, if clinical
submitdate  date  Date when this vaccine order was submitted, if clinical
"""
    end
  end
end
