module Leo
	class Appointments < Grape::API
		version 'v1', using: :path, vendor: 'leo-health'
		format :json
		prefix :api

		rescue_from :all, :backtrace => true
		formatter :json, JSendSuccessFormatter
  	error_formatter :json, JSendErrorFormatter
		default_error_status 400

    resource :appointments do 
      desc "Return an appointment"
      params do 
        requires :id, type: Integer, desc: "User id"
      end
      route_param :id do 
        get do
          Appointment.find(params[:id])
        end
      end

      desc "Create a Appointment"
      params do
        requires :patient_id, 			type: Integer, 	desc: "Leo Patient Id"
        requires :provider_id,  		type: Integer, 	desc: "Leo Provider Id"
        requires :date,     				type: Date, 		desc: "Appointment Date"
        requires :start_time,   		type: Time,	 		desc: "Appointment Start Time"
        requires :duration,        	type: Integer, 	desc: "Appointment Duration"
        requires :practice_id,			type: Integer,	desc: "Practice Id for the location of the appointment"
      end
      post do
      	# set up variables
      	appointment_start_time = Chronic.try(:parse, params[:start_time])
      	appointment_date = Chronic.try(:parse, params[:date])
      	provider_id = params[:provider_id]
      	patient_id = params[:patient_id]
      	duration = params[:duration]
      	practice_id = params[:practice_id]
      	
      	if appointment_start_time.nil? or appointment_date.nil?
      		error!({error_code: 422, error_message: "The appointment date or time is not valid"}, 422)	
      		return
      	end
      	if duration < Appointment::MIN_DURATION or duration > Appointment ::MAX_DURARTION
      		error!({error_code: 422, error_message: "The appointment duration is not valid"}, 422)	
      		return
      	end
      	if User.find(provider_id).has_role :provider == false
      		error!({error_code: 422, error_message: "A physician with that id does not exist"}, 422)
      		return 
      	end
      	if User.find(patient_id).has_role :child == false
      		error!({error_code: 422, error_message: "A patient with that id does not exist"}, 422)
      		return 
      	end
      	#TODO: Implement a collision test for appointment start time + duration running into another appointment
        if Appointment.where(provider_id: provider_id, appointment_date: appointment_date, 
        	appointment_start_time: appointment_start_time).count > 0
          error!({error_code: 422, error_message: "The physician is not available at that day and time"}, 422)
          return
        end

        appointment = Appointment.create!(
        {
          patient_id:   patient_id,
          provider_id:  provider_id,
          duration:     duration,
          practice_id:  practice_id,
          start_time: 	appointment_start_time,
          date: 				appointment_date,
          created_by_user_id: current_user.id
          
        })
      end
    end

	end
end
