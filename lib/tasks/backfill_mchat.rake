namespace :backfill do
  desc 'back fill mchat'
  task mchat: :environment do
    appointment_types = [AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[18], AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[24]]
    well_visits = Appointment.joins(:appointment_type).where(appointment_type: {athena_id: appointment_types})
    general_well_visits = Appointment.joins(:appointment_type).where(appointment_type: {athena_id: AppointmentType::WELL_VISIT_TYPE_ATHENA_ID})
    total = general_well_visits.includes(:patient).select do |appt|
      time_to_start =(appt.start_datetime - appt.patient.birth_date.to_datetime - 1.months).abs
      time_to_start < 18.months || time_to_start < 24.months
    end + well_visits
    puts "#{total.count} surveys needs to be generated"
  end
end
