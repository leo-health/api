namespace :backfill do
  desc 'back fill mchat'
  task mchat: :environment do
    appointment_types = [AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[18], AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[24]]
    well_visits = Appointment.joins(:appointment_type).where(appointment_type: {athena_id: appointment_types})
    general_well_visits = Appointment.joins(:appointment_type).where(appointment_type: {athena_id: AppointmentType::WELL_VISIT_TYPE_ATHENA_ID})
    total = general_well_visits.includes(:patient).select do |appt|
      appt.milestone_from_birth?(18, 1) || appt.milestone_from_birth?(24, 1)
    end + well_visits
    puts "#{total.count} surveys needs to be generated"
  end
end
