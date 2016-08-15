module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      ENTITIES = %w(image avatar role provider insurance_plan insurer user
                    escalation_note system appointment_status closure_reason
                    appointment_type message short_user full_message patient conversation practice_schedule
                    provider_leave practice appointment short_patient short_conversation deep_link_card card family session
                    vital allergy medication vaccine user_generated_health_record form patient_insurance phr)

      ENTITIES.each do |entity_name|
        require_relative "../entities/#{entity_name}_entity"
      end

      require_relative 'error_formatter'
      require_relative 'success_formatter'

      include ExceptionHandler
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

        def authenticated_and_complete
          error!('401 Unauthorized', 401) unless current_user.try(:complete?)
        end

        def find_user_by_invitation_token
          error!('401 Unauthorized', 401) unless user = User.find_by(invitation_token: params[:invitation_token])
          if user.invitation_token_expired?
            error!({error_code: 422, user_message: 'Your invitation has expired, please request another invite.' }, 422)
          end
          user
        end

        def current_user
          @session = Session.find_by_authentication_token(params[:authentication_token])
          @session.try(:user)
        end

        def create_success object, device_type=nil
          if object.save
            present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize, device_type: device_type
          else
            error!({error_code: 422, user_message: object.errors.full_messages.first }, 422)
          end
        end

        def render_success object, device_type=session_device_type
          present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize, device_type: device_type
        end

        def update_success object, update_params, entity_name=nil, device_type=session_device_type
          if object.update_attributes(update_params)
            entity_name ||=  object.class.name
            full_entity_name = "Leo::Entities::#{entity_name}Entity".constantize
            present entity_name.downcase.to_sym, object,
                    with: full_entity_name,
                    device_type: device_type
          else
            error!({error_code: 422, user_message: object.errors.full_messages.first }, 422)
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
                     subscriptions appointment_statuses forms patient_insurances
                     deep_links ios_configuration validated_json payments_listener
                     subscriptions staff_profiles)

      ENDPOINTS.each do |endpoint|
        require_relative endpoint
        mount "Leo::V1::#{endpoint.camelize}".constantize
      end
    end
  end
end
