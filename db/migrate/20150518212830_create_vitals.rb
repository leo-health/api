class CreateVitals < ActiveRecord::Migration
  def change
    create_table :vitals do |t|
      t.belongs_to :patient, index: true

      t.integer :athena_id, index: true, default: 0, null: false #vitalid
      t.datetime :taken_at #readingtaken
      t.string :measurement, default: '', null: false #clinicalelementid
      t.string :value, default: '', null: false #value

      #figure out which vitals are needed

      t.timestamps null: false
      """
key string  Key for this vital group. E.g., HEIGHT.
abbreviation  string  Short human-readable string for this vital group. E.g., Ht.
ordering  integer Configured order for this vital group
readings  string  List of vital attribute readings. One entry per attribute (so the temperature and where the temperature was taken are two different readings, tied together by the readingid
  vitalid integer Unique ID for this vital attribute reading. Used to update/delete this reading.
  clinicalelementid string  Key used to identify the vital attribute
  source  string  The source of this reading. E.g. Encounter
  sourceid  integer External key to source. E.g., encounterid
  readingid integer Numeric key used to tie related and distinguish separate readings. So the diastolic and systolic blood pressure should have the same readingid.
  readingtaken  time  Timestamp that the reading was taken. The timezone is local to the practice.
  value string  The value of this reading. NOTE: for numeric values, the units are always in the 'native' units per the configuration.
  code  string  Code indentifier for the reading.
  codeset string  Codeset of the code.
  codedescription string  Description of the code identifier.
"""
    end
  end
end
