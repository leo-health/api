class Member < User
  has_many :booked_appointments, foreign_key: "booked_by_id", class_name: "Appointment"
end
