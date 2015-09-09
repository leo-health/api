class Insurer < ActiveRecord::Base
  has_many :insurance_plans

  validates :insurer_name, presence: true
end
