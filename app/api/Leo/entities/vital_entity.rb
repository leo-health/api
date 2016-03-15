module Leo
  module Entities
    class VitalEntity < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :taken_at
      end
      expose :value
      expose :unit
      expose :percentile
    end
  end
end
