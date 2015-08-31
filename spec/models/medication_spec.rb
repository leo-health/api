require 'rails_helper'

RSpec.describe Medication, type: :model do
  patient_id 1
  athena_id 0
  medication "medication"
  sig "sig"
  patient_note "patient_note"
  started_at DateTime.now
  ordered_at DateTime.now
end
