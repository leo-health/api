class Vital < ActiveRecord::Base
  MEASUREMENT_HEIGHT = "VITALS.HEIGHT"
  MEASUREMENT_WEIGHT = "VITALS.WEIGHT"
  belongs_to :patient
end
