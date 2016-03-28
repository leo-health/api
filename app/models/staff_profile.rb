class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{ staff }, class_name: "User"

  validates :staff, presence: true
end
