module Leo
  module V1
    class API < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      require_relative '../entities/avatar_entity'
      require_relative '../entities/role_entity'
      require_relative '../entities/insurer_entity'
      require_relative '../entities/user_entity'
      require_relative '../entities/escalation_note_entity'
      require_relative '../entities/system_entity'
      require_relative '../entities/appointment_status_entity'
      require_relative '../entities/appointment_type_entity'
      require_relative '../entities/message_entity'
      require_relative '../entities/full_message_entity'
      require_relative '../entities/patient_entity'
      require_relative '../entities/conversation_entity'
      require_relative '../entities/conversation_with_messages_entity'
      require_relative '../entities/practice_entity'
      require_relative '../entities/appointment_entity'
      require_relative '../entities/card_entity'
      require_relative '../entities/family_entity'
      require_relative '../entities/session_entity'
      require_relative '../entities/vital_entity'
      require_relative '../entities/allergy_entity'
      require_relative '../entities/medication_entity'
      require_relative '../entities/vaccine_entity'
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
      require_relative 'read_receipts'
      require_relative 'practices'
      require_relative 'appointment_types'
      require_relative 'families'
      require_relative 'cards'
      require_relative 'insurers'
      require_relative 'enrollments'
      require_relative 'patient_enrollments'
      require_relative 'avatars'
      require_relative 'health_records'
      require_relative 'escalation_notes'

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

        def render_success object
          if object.save
            present object.class.name.downcase.to_sym, object, with: "Leo::Entities::#{object.class.name}Entity".constantize
          else
            error!({error_code: 422, error_message: object.errors.full_messages }, 422)
          end
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
      mount Leo::V1::Practices
      mount Leo::V1::ReadReceipts
      mount Leo::V1::Messages
      mount Leo::V1::AppointmentTypes
      mount Leo::V1::Families
      mount Leo::V1::Cards
      mount Leo::V1::Insurers
      mount Leo::V1::Enrollments
      mount Leo::V1::PatientEnrollments
      mount Leo::V1::Avatars
      mount Leo::V1::HealthRecords
      mount Leo::V1::EscalationNotes

      add_swagger_documentation(
          base_path: "/api",
          hide_documentation_path: true
      )
    end
  end
end
