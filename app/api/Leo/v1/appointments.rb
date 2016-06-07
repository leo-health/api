module Leo
  module V1
    class Appointments < Grape::API
      include Grape::Kaminari

      resource :appointments do
        helpers do
          params :appointment_params do
            requires :start_datetime, type: DateTime, allow_blank: false
            requires :appointment_status_id, type: Integer, allow_blank: false
            requires :appointment_type_id, type: Integer, allow_blank: false
            requires :provider_id, type: Integer, allow_blank: false
            requires :patient_id, type: Integer, allow_blank: false
            requires :practice_id, type: Integer, allow_blank: false
            optional :notes, type: String
            optional :athena_id, type: Integer
          end
        end

        before do
          authenticated
        end

        desc "create an appointment"
        params do
          use :appointment_params
        end

        post do
          generate_appointment
        end

        desc "show an appointment"
        get ":id" do
          if appointment = Appointment.find(params[:id])
            authorize! :read, appointment
            render_success appointment
          end
        end

        desc "cancel an appointment"
        delete ":id" do
          cancel_appointment
        end

        desc "reschedule an appointment"
        params do
          use :appointment_params
        end

        put ":id" do
          appointment = Appointment.find(params[:id])
          appointment_rescheduled = appointment.start_datetime != params[:start_datetime] || appointment.provider_id != params[:provider_id]
          if appointment_rescheduled
            Appointment.transaction do
              cancel_appointment
              generate_appointment
            end
          else
            duration = AppointmentType.find(params[:appointment_type_id]).duration
            appointment_params = declared(params, include_missing: false).merge(duration: duration)
            update_success appointment, appointment_params
          end
        end

        desc "return appointments of current user"
        get do
          if current_user.has_role? :guardian
            appointments = Appointment.booked.where(patient_id: current_user.family.patients.pluck(:id))
          elsif current_user.has_role? :clinical
            appointments = Appointment.booked.where(provider: current_user.provider)
          end
          appointments.order(start_datetime: :asc)
          authorize! :read, Appointment
          present :appointments, appointments, with: Leo::Entities::AppointmentEntity
        end
      end

      helpers do
        def generate_appointment
          error!({error_code: 422, user_message: "Appointment start time must be at least 15 minutes in the future" }, 422) if params[:start_datetime] < (DateTime.now + Appointment::MIN_INTERVAL_TO_SCHEDULE)
          duration = AppointmentType.find(params[:appointment_type_id]).duration
          appointment_params = declared(params, include_missing: false).merge(duration: duration, booked_by: current_user)
          appointment = Appointment.new(appointment_params)
          authorize! :create, appointment
          appointment.save!
          PostAppointmentJob.new(appointment).start
          create_success appointment
        end

        def cancel_appointment
          appointment = Appointment.find(params[:id])
          authorize! :destroy, appointment
          appointment.appointment_status = AppointmentStatus.cancelled
          appointment.save!
          Slot.where(appointment: appointment).destroy_all if appointment.athena_id > 0
          PostAppointmentJob.new(appointment).start
          create_success appointment
        end
      end
    end
  end
end
