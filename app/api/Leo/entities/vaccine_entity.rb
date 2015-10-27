module Leo
  module Entities
    class VaccineEntity < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.nil? ? nil : dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :administered_at
      end
      expose :vaccine
    end
  end
end
