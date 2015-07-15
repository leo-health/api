class Patient < ActiveRecord::Base::User
    belongs_to :family
    has_many :medications
    has_many :photos
    has_many :vaccines
    has_many :vitals
    has_many :insurances
end
