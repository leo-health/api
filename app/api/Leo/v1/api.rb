module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      ENTITIES = %w(avatar role insurer user escalation_note system appointment_status
                    appointment_type message full_message patient conversation enrollment
                    conversation_with_messages practice appointment short_user short_conversation card
                    family session vital allergy medication vaccine user_generated_health_record
                    patient_insurance
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
          @current_user ||= Session.find_by_authentication_token(params[:authentication_token]).try(:user)
        end

        def render_success object
          if object.save
            present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize
          else
            error!({error_code: 422, error_message: object.errors.full_messages }, 422)
          end
        end
      end

      ENDPOINTS = %w(appointments appointment_slots conversations sessions users
                     roles passwords patients practices read_receipts messages
                     appointment_types families cards insurers enrollments
                     patient_enrollments avatars health_records notes pushers
                     appointment_statuses patient_insurances)

      ENDPOINTS.each do |endpoint|
        require_relative endpoint
        mount "Leo::V1::#{endpoint.camelize}".constantize
      end
    end
  end
end
