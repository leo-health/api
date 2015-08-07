module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      require_relative '../../../../app/api/Leo/entities/appointment_entity'
      require_relative '../../../../app/api/Leo/entities/message_entity'
      require_relative '../../../../app/api/Leo/entities/conversation_entity'
      require_relative '../../../../app/api/Leo/entities/conversation_with_messages_entity'
      require_relative '../../../../app/api/Leo/entities/role_entity'
      require_relative '../../../../app/api/Leo/entities/user_entity'
      require_relative '../../../../app/api/Leo/entities/patient_entity'
      require_relative '../../../../app/api/Leo/entities/session_entity'
      require_relative '../../../../lib/api/validations/role_exists'
      require_relative 'exception_handler'
      require_relative 'error_formatter'
      require_relative 'success_formatter'
      require_relative 'appointments'
      require_relative 'appointment_slots'
      require_relative 'conversations'
      require_relative 'roles'
      require_relative 'sessions'
      require_relative 'users'
      require_relative 'patients'
      require_relative 'messages'
      require_relative 'passwords'

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
          (Session.find_by_authentication_token(params[:authentication_token]).try(:user)) if params[:authentication_token]
        end
      end

      mount Leo::V1::Appointments
      mount Leo::V1::AppointmentSlots
      mount Leo::V1::Conversations
      mount Leo::V1::Sessions
      mount Leo::V1::Users
      mount Leo::V1::Roles
      mount Leo::V1::Passwords
      mount Leo::V1::Patients
      mount Leo::V1::Messages

      add_swagger_documentation(
          base_path: "/api",
          hide_documentation_path: true
      )
    end
  end
end
