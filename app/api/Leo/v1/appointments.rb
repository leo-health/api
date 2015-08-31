module Leo
  module V1
    class Appointments < Grape::API
      include Grape::Kaminari

      resource :appointments do
        before do
          authenticated
        end

        desc "create an appointment"
        params do
          requires :start_datetime, type: DateTime, allow_blank: false
          requires :status, type: String, allow_blank: false
          requires :appointment_type_id, type: Integer, allow_blank: false
          requires :provider_id, type: Integer, allow_blank: false
          requires :patient_id, type: Integer, allow_blank: false
          optional :notes, type: String
          optional :athena_id, type: Integer
        end

        post do
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

        desc "show an appointment"
        get ":id" do
          if appointment = Appointment.find(params[:id])
            authorize! :read, appointment
            present :appointment, appointment, with: Leo::Entities::AppointmentEntity
          end
        end

        desc "cancel an appointment"
        delete ':id' do
          if appointment = Appointment.find(params[:id])
            authorize! :destroy, appointment
            appointment.destroy
          end
        end
      end

      namespace 'users/:user_id/appointments' do
        before do
          authenticated
        end

        after_validation do
          @user = User.find(params[:user_id])
        end

        desc "return appointments of a user"
        get do
          if @user.has_role? :guardian
            appointments = @user.booked_appointments
          elsif @user.has_role? :clinical
            appointments = @user.provider_appointments
          end
          authorize! :read, Appointment
          present :appointments, appointments, with: Leo::Entities::AppointmentEntity
        end
      end
    end
  end
end
