class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{where('role_id != ?', 4)}, class_name: "User"

  validates :staff, presence: true
end
