class HealthRecord < ActiveRecord::Base
    belongs_to :user
    has_many :medications
    has_many :photos
    has_many :vaccines
    has_many :vitals
    has_many :insurances
end
