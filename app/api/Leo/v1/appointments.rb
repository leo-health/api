module Leo
  module V1
    class Appointments < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      resource :appointments do

        # All requests pertaining to appointments require authentication
        before do
          authenticated_user
        end

        desc "Return all relevant appointments for current user"
        # get "/appointmeents"
        get do
          present Appointment.for_user(current_user), with: Leo::Entities::AppointmentEntity
        end

        desc "Return an appointment"
        # get "/appointmeents/{id}"
        params do
          requires :id, type: Integer, desc: "User id"
        end
        route_param :id do
          get do
            {appointments: Appointment.find(params[:id])}
          end
        end

        desc "Create a Appointment"
        # post "/appointments"
        params do
          requires :patient_id, 			type: Integer, 	desc: "Leo HealthRecord Id"
          requires :provider_id,  		type: Integer, 	desc: "Leo Provider Id"
          requires :date,     				type: Date, 		desc: "Appointment Date"
          requires :start_time,   		type: Time,	 		desc: "Appointment Start Time"
          requires :duration,        	type: Integer, 	desc: "Appointment Duration"
          requires :practice_id,			type: Integer,	desc: "Practice Id for the location of the appointment"
        end
        post do
          # set up variables
          appointment_start_time = params[:start_time]
          appointment_date = params[:date]
          provider_id = params[:provider_id]
          patient_id = params[:patient_id]
          duration = params[:duration]
          practice_id = params[:practice_id]

          if appointment_start_time.nil? or appointment_date.nil?
            error!({error_code: 422, error_message: "The appointment date or time is not valid"}, 422)
            return
          end
          if duration < Appointment.MIN_DURATION or duration > Appointment.MAX_DURATION
            error!({error_code: 422, error_message: "The appointment duration is not valid"}, 422)
            return
          end
          if User.find(provider_id).has_role? :clinical == false
            error!({error_code: 422, error_message: "A physician with that id does not exist"}, 422)
            return
          end
          if User.find(patient_id).has_role? :patient == false
            error!({error_code: 422, error_message: "A patient with that id does not exist"}, 422)
            return
          end
          #TODO: Implement a collision test for appointment start time + duration running into another appointment
          if Appointment.where(leo_provider_id: provider_id, appointment_date: appointment_date,
                               appointment_start_time: appointment_start_time).count > 0
            error!({error_code: 422, error_message: "The physician is not available at that day and time"}, 422)
            return
          end

          appointment = Appointment.create!(
              {
                  leo_patient_id:   patient_id,
                  leo_provider_id:  provider_id,
                  duration:     duration,
                  #practice_id:  practice_id, #TODO: add practice_id to appointment model
                  appointment_start_time: 	appointment_start_time,
                  appointment_date: 				appointment_date,
                  booked_by_user_id: current_user.id,
                  family_id: current_user.family_id
              })
        end
      end
    end
  end
end
