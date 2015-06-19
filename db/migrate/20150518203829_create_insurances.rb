class CreateInsurances < ActiveRecord::Migration
  def change
    create_table :insurances do |t|
      t.belongs_to :user, index: true

      t.integer :athena_id, index: true, default: 0, null: false #insuranceid
      t.string :plan_name #insuranceplanname
      t.string :plan_phone #insurancephone
      t.string :plan_type #insurancetype
      t.string :policy_number #policynumber
      t.string :holder_ssn #insurancepolicyholderssn
      t.datetime :holder_dob #insurancepolicyholderdob
      t.string :holder_sex #insurancepolicyholdersex
      t.string :holder_last_name #insurancepolicyholderlastname
      t.string :holder_first_name #insurancepolicyholderfirstname
      t.string :holder_middle_name #insurancepolicyholdermiddlename
      t.string :holder_address_1 #insurancepolicyholderaddress1
      t.string :holder_address_2 #insurancepolicyholderaddress2 (optional)
      t.string :holder_city #insurancepolicyholdercity
      t.string :holder_state #insurancepolicyholderstate
      t.string :holder_zip #insurancepolicyholderzip
      t.string :holder_country #insurancepolicyholdercountrycode
      t.integer :primary #sequencenumber 1=prim, 2=sec, others?=cash

      t.timestamps null: false

"""
insurancepackageid  integer ID of the specific insurance package.
insuranceidnumber string  The insurance policy ID number (as presented on the insurance card itself).
insurancepolicyholderaddress1 string  The first address line of the insurance policy holder.
insurancepolicyholderaddress2 string  The second address line of the insurance policy holder.
insurancepolicyholder string  The full name of the insurance policy holder.
insuranceid integer The athena insurance policy ID.
insurancepolicyholdercity string  The city of the insurance policy holder.
insurancepolicyholdercountrycode  string  The country code (3 letter) of the insurance policy holder.
insurancepolicyholdercountryiso3166 string  The ISO 3166 country code of the insurance policy holder.
insurancepolicyholderdob  string  The DOB of the insurance policy holder (mm/dd/yyyy).
insurancepolicyholderfirstname  string  The first name of the insurance policy holder. Except for self-pay, required for new policies.
insurancepolicyholderlastname string  The last name of the insurance policy holder. Except for self-pay, required for new policies.
insurancepolicyholdersex  select  The sex of the insurance policy holder. Except for self-pay, required for new policies.
insuranceplanname string  Name of the specific insurance package.
insurancepolicyholdermiddlename string  The middle name of the insurance policy holder.
insurancepolicyholderssn  string  The SSN of the insurance policy holder.
insurancepolicyholderstate  string  The state of the insurance policy holder.
insurancepolicyholdersuffix string  The suffix of the insurance policy holder.
eligibilitymessage  string  The message, usually from our engine, of the eligibility check.
insurancepolicyholderzip  string  The zip of the insurance policy holder.
relationshiptoinsured string  This patient's relationship to the policy holder (text).
sequencenumber  string  1 = primary, 2 = secondary. Must have a primary before a secondary.
eligibilityreason string  The source of the current status. Athena is our eligibility engine.
insurancetype string  Type of insurance. E.g., Medicare Part B, Group Policy, HMO, etc.
eligibilitylastchecked  string  Date the eligibility was last checked.
eligibilitystatus string  Current eligibility status of this insurance package.
insurancephone  string  The phone number for the insurance company. Note: This defaults to the insurance package phone number. If this is set, it will override it. Likewise if blanked out, it will go back to default.
policynumber  string  The insurance group number. This is sometimes present on an insurance card.
relationshiptoinsuredid integer This patient's relationship to the policy holder (as an ID). See the mapping.
ircname string  Insurance category / company. E.g., United Healthcare, BCBS-MA, etc.
slidingfeeplanid  integer If the patient is on a sliding fee plan, this is the ID of that plan. See /slidingfeeplans.
"""
    end
  end
end
