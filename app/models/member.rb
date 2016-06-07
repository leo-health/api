class Member < User
  MEMBER_TYPES = [
    { id: 1, member_type_name: :Incomplete },
    { id: 2, member_type_name: :Delinquent },
    { id: 3, member_type_name: :Member },
    { id: 4, member_type_name: :Exempted }
  ]

  # Unused but will need later
  # FUTURE_MEMBER_TYPES = [
  #   { id: 5, member_type_name: :Expecting },
  #   { id: 6, member_type_name: :Preview }
  # ]

  has_many :booked_appointments, foreign_key: "booked_by_id", class_name: "Appointment"
end
