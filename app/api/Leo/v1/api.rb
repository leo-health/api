module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      require_relative '../../../../app/api/Leo/entities/appointment_entity'
      require_relative '../../../../app/api/Leo/entities/conversation_participant_entity'
      require_relative '../../../../app/api/Leo/entities/message_entity'
      require_relative '../../../../app/api/Leo/entities/conversation_entity'
      require_relative '../../../../app/api/Leo/entities/conversation_with_messages_entity'
      require_relative '../../../../app/api/Leo/entities/role_entity'
      require_relative '../../../../app/api/Leo/entities/user_entity'
      require_relative '../../../../app/api/Leo/entities/user_with_auth_entity'
      require_relative '../../../../lib/api/validations/role_exists'
      require_relative 'error_formatter'
      require_relative 'success_formatter'
      require_relative 'appointments'
      require_relative 'conversations'
      require_relative 'roles'
      require_relative 'sessions'
      require_relative 'users'

      rescue_from :all, :backtrace => true
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter
      default_error_status 400

      rescue_from Grape::Exceptions::ValidationErrors do |e|
        data = e.map { |k,v| {
            params: k,
            messages: (v.class.name == "Grape::Exceptions::Validation" ? v.to_s :  v.map(&:to_s)) }
        }
        resp = {status: 'error', data: data }
        rack_response resp.to_json, 422
      end

      before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
      end


      helpers do
        def warden
          env['warden']
        end

        def authenticated
          if warden.authenticated?
            return true
          elsif params[:access_token] and Session.find_by_authentication_token(params[:access_token]).try(:user)
            return true
          else
            error!('401 Unauthorized', 401)
          end
        end

        def warden
          env['warden']
        end

        def current_user
          warden.user || (User.find_by_authentication_token(params[:access_token]) if params[:access_token])
        end

        def authenticated_user
          authenticated
          error!('401 Unauthorized', 401) unless current_user
        end
      end

      get do
        {message: "Welcome to the Leo API"}
      end

      mount Leo::V1::Appointments
      mount Leo::V1::Conversations
      mount Leo::V1::Sessions
      mount Leo::V1::Users

      add_swagger_documentation(
          base_path: "/api",
          hide_documentation_path: true
      )
    end
  end
end
