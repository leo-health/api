class Medication < ActiveRecord::Base
  belongs_to :health_record

  validates :health_record, presence: true
end
