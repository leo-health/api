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
      expose :measurement_type
      expose :formatted_value_with_units
      expose :formatted_values
      expose :formatted_units

      private

      def measurement_type
        measurement = object[:measurement]
        if measurement == Vital::MEASUREMENT_HEIGHT
          "height"
        elsif measurement == Vital::MEASUREMENT_WEIGHT
          "weight"
        else
          measurement
        end        
      end

      def formatted_values
        i = 0
        formatted_value_with_units.split.select{ |x| i+=1; i.odd? }
      end

      def formatted_units
        i = 0
        formatted_value_with_units.split.select{ |x| i+=1; i.even? }
      end

      def formatted_value_with_units
        if object[:measurement] == Vital::MEASUREMENT_HEIGHT
          format_inches_to_feet_and_inches(object[:value])
        elsif object[:measurement] == Vital::MEASUREMENT_WEIGHT
          format_pounds_to_pounds_and_ounces(object[:value])
        else
          "#{object[:value]} #{object[:unit]}".strip
        end
      end

      def format_inches_to_feet_and_inches(total_inches)
        whole_inches = total_inches.floor
        fractional_inches = total_inches - whole_inches
        feet = whole_inches / 12
        inches = whole_inches % 12 + fractional_inches
        inches_plurality = if inches == 1 then "inch" else "inches" end
        inches_format = "#{"#{inches.round(2)}".chomp(".0")} #{inches_plurality}"
        if feet == 0
          inches_format
        else
          feet_plurality = if feet == 1 then "foot" else "feet" end
          "#{feet} #{feet_plurality} #{inches_format}"
        end
      end

      def format_pounds_to_pounds_and_ounces(total_pounds)
        whole_pounds = total_pounds.floor
        ounces = ((total_pounds % 1) * 16).round(1)
        ounces_plurality = if ounces == 1 then "ounce" else "ounces" end
        ounces_format = "#{"#{ounces}".chomp(".0")} #{ounces_plurality}"

        if whole_pounds == 0
          ounces_format
        else
          pounds_plurality = if whole_pounds == 1 then "pound" else "pounds" end
          "#{whole_pounds} #{pounds_plurality}%s" % (" #{ounces_format}" unless ounces == 0)
        end
      end
    end
  end
end
