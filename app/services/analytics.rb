class Analytics

  class << self

    def patients_with_appointments_in(time_range)
      Patient.joins(:appointments).where(appointments: {start_datetime: time_range}).uniq(:id)
    end

    def new_patients_enrolled_in_practice
      Patient.group("date_trunc('month', created_at)").count
    end

    def visits_booked_by(role, time_range)
      Appointment.where(start_datetime: time_range).includes(:booked_by).where(booked_by: {role_id: role.id})
    end

    def guardians_who_sent_messages(time_range)
      User.joins(:sent_messages).where(sent_messages: {created_at: time_range}).guardians.distinct
    end

    def appointments_count(time_range)
      Appointment.where(start_datetime: time_range).count
    end
  end

end
