class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications do |t|
      t.belongs_to :patient, index: true

      t.integer :athena_id, index: true, default: 0, null: false #medicationid
      t.string :medication, default: '', null: false #medication
      t.string :sig, default: '', null: false #unstructuredsig (optional)
      t.string :patient_note, default: '', null: false #patientnote (optional)
      t.datetime :started_at #events.eventdata, events.type=START (optional)
      t.datetime :ended_at #events.eventdata, events.type=END (optional)
      t.datetime :ordered_at #events.eventdata, events.type=ORDER (optional)
      t.datetime :filled_at #events.eventdata, events.type=FILL (optional)
      t.datetime :entered_at #events.eventdata, events.type=ENTER (optional)
      t.datetime :hidden_at #events.eventdata, events.type=HIDE (optional)

      t.timestamps null: false
"""
medicationentryid string  Primary ID for this medication entry. Those starting with C are clinical prescriptions, and those starting with H are historical (entered, downloaded, etc).
medicationid  integer Athena ID for this medication.
medication  string  The name of the medication.
isstructuredsig boolean Whether the sig for this entry is structured.
structuredsig string  Components of the structured sig.
  dosageaction  string  How the medication is taken. Examples are Chew, Take, Inhale, etc.
  dosagequantityvalue integer How many of this med is taken.
  dosagequantityunit  string  The unit of the quantity. Example: tablets, sprays, etc.
  dosagefrequencyvalue  integer How many times (in the given time unit) this should be taken.
  dosagefrequencyunit string  The unit of the frequency. Example: per day, per week.
  dosagefrequencydescription  string  A standardized patient-friendly frequency. Example: 6 per day becomes every 4 hours.
  dosageroute string  How this medication is taken. Example: oral, inhalation, intranasal, etc.
  dosageadditionalinstructions  string  Additional instructions. Example: with meals
  dosagedurationvalue integer How many duration time units this medication should be taken form.
  dosagedurationunit  string  The unit of the duration. Example: days. So take this for days.
unstructuredsig string  The unstructured sig for this medication, if any. If there is a structured sig, this will contain the formatted version of that sig.
source  string  How this medication was entered. This can be the ordering provider, a medication history download (express scripts, medco, etc), ATHENA (which means it was entered manually), etc.
encounterid integer If this was a prescription, this contains the ID of the encounter where it was ordered or administered
createdby string  The athena username of the person who entered or ordered the medication. Downloaded medications have INTERFACE for this field.
approvedby  string  For clinical prescriptions, the athena username of the person who approved this prescription.
orderingmode  string  The ordering mode for prescriptions. Can be PRESCRIBE, DISPENSE, or ADMINISTER.
refillsallowed  integer The number of refills allowed when this medication was ordered.
issafetorenew boolean 
stopreason  date  The reason why this medication was stopped.
providernote  string  Non-patient facing note for ths prescription. Labeled internal note in the UI.
patientnote string  HealthRecord-facing note for this prescription. Labeled note in the UI.
events  string  The list of events for this medication. Can be START, END, ORDER, ENTER, FILL, or HIDE.
  type  string  The event type. Can be START, END, ORDER, ENTER, FILL, or HIDE.
  eventdate date  The date this event occurred
ndcoptions  string  The list of NDC numbers that correspond to this medication.
rxnorm  string  The list of RxNorm Identifiers that correspond to this medication. This list may contain both branded and generic identifiers

"""
    end
  end
end
