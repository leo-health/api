class Practice < ActiveRecord::Base
  has_many :staff, ->{ where role_id: [2, 3, 5] }, class_name: "User"
  has_many :guardians, ->{ where role_id: 4 }, class_name: "User"
  has_many :appointments
  has_many :practice_schedules

  validates :name, presence: true
end
