class Allergy < ActiveRecord::Base
  belongs_to :patient
  
  def table_name
    'allergies'
  end
end
