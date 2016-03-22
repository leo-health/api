class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{where.not(role: Role.find_by(name: :guardian))}, class_name: "User"

  validates :staff, presence: true
end
