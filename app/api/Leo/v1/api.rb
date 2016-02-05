module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      ENTITIES = %w(image avatar role insurance_plan insurer user escalation_note system appointment_status
                    appointment_type message short_user full_message patient conversation enrollment
                    practice appointment short_conversation card family session vital allergy medication vaccine
                    user_generated_health_record form patient_insurance
                   )

      ENTITIES.each do |entity_name|
        require_relative "../entities/#{entity_name}_entity"
      end

      require_relative 'exception_handler'
      require_relative 'error_formatter'
      require_relative 'success_formatter'

      include Leo::V1::ExceptionsHandler
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
      end

      helpers do
        def authenticated
          error!('401 Unauthorized', 401) unless current_user
        end

        def current_user
          return unless params[:authentication_token]
          @session = Session.find_by_authentication_token(params[:authentication_token])
          @current_user ||= @session.try(:user)
        end

        def create_success object, device_type=nil
          if object.save
            present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize, device_type: device_type
          else
            error!({error_code: 422, error_message: object.errors.full_messages }, 422)
          end
        end

        def render_success object, device_type=session_device_type
          present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize, device_type: device_type
        end

        def update_success object, update_params, device_type=session_device_type
          if object.update_attributes(update_params)
            present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize, device_type: device_type
          else
            error!({error_code: 422, error_message: object.errors.full_messages }, 422)
          end
        end

        def image_decoder(image)
          data = StringIO.new(Base64.decode64(image))
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.content_type = "image/png"
          data.original_filename = "uploaded_image.png"
          data
        end

        def session_device_type
          @session.device_type.gsub(/\s+/, "").to_sym if @session.device_type
        end
      end

      ENDPOINTS = %w(appointments appointment_slots conversations sessions users
                     roles passwords patients practices read_receipts messages
                     appointment_types families cards insurers enrollments
                     patient_enrollments avatars health_records notes pushers
                     appointment_statuses forms patient_insurances)

      ENDPOINTS.each do |endpoint|
        require_relative endpoint
        mount "Leo::V1::#{endpoint.camelize}".constantize
      end
    end
  end
end
