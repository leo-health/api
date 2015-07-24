class Patient < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :family
  belongs_to :role
  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
end
