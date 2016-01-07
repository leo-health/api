class InsurancePlan < ActiveRecord::Base
  belongs_to :insurer
  has_many :users
  
  validates :insurer, :plan_name, presence: true
end
