class InsurancePlan < ActiveRecord::Base
  belongs_to :insurer

  validates :insurer, :plan_name, presence: true
end
