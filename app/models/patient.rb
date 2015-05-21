class Patient < ActiveRecord::Base
    belongs_to :user
    has_many :medications
    has_many :photos
    has_many :vaccines
    has_many :vitals
end
