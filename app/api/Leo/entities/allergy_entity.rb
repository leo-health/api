module Leo
  module Entities
    class AllergyEntity < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.nil? ? nil : dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :onset_at
      end
      expose :allergen
    end
  end
end
