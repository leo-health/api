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
            present :appointment, appointment, with: Leo::Entities::AppointmentEntity
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
          Appointment.transaction do
            cancel_appointment
            generate_appointment
          end
        end

        desc "return appointments of current user"
        get do
          if current_user.has_role? :guardian
            appointments = current_user.booked_appointments
          elsif current_user.has_role? :clinical
            appointments = current_user.provider_appointments
          end
          authorize! :read, Appointment
          present :appointments, appointments, with: Leo::Entities::AppointmentEntity
        end
      end

      helpers do
        def generate_appointment
          duration = AppointmentType.find(params[:appointment_type_id]).duration
          appointment_params = declared(params, include_missing: false).merge(duration: duration)
          appointment = current_user.booked_appointments.new(appointment_params)
          authorize! :create, appointment
          if appointment.save
            present :appointment, appointment, with: Leo::Entities::AppointmentEntity
          else
            error!({error_code: 422, error_message: appointment.errors.full_messages }, 422)
          end
        end

        def cancel_appointment
          appointment = Appointment.find(params[:id])
          authorize! :destroy, appointment
          appointment.destroy
        end
      end
    end
  end
end
