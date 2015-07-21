class Patient < ActiveRecord::Base
  belongs_to :family

  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
end
