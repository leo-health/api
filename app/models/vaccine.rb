class Vaccine < ActiveRecord::Base
    belongs_to :patient
    validates_presence_of :patient
end
