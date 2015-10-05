module Leo
  module Entities
    class MedicationEntity < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.nil? ? nil : dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :started_at
        expose :entered_at
      end
      expose :medication
      expose :sig
      expose :patient_note
    end
  end
end
