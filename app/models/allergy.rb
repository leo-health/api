class Allergy < ActiveRecord::Base
  belongs_to :health_record

  validates :health_record, presence: true

  def self.table_name
    'allergies'
  end
end
