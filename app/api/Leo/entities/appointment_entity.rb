module Leo
  module Entities
    class AppointmentEntity < Grape::Entity
      expose :id
      expose :leo_provider_id, documentation: {type: "integer", desc: "The Leo provider id." }
      expose :leo_patient_id,  documentation: {type: "integer", desc: "The Leo patient id." }
      expose :booked_by_user_id, documentation: {type: "integer", desc: "The Leo user id that booked this appointment." }
      expose :leo_appointment_type, documentation: {type: "string", desc: "Leo appointment type" }
      expose :appointment_status
      expose :appointment_date, documentation: {type: "date", desc: "Appointment Date" }
      expose :appointment_start_time, documentation: {type: "string", desc: "Appointment Start time" }
      expose :duration, documentation: {type: "integer", desc: "Appointment Duration" }
    end
  end
end
