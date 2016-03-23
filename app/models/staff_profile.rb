class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{where(role: Role.staff)}, class_name: "User"

  validates :staff, presence: true
end
