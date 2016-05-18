module Leo
  module V1
    class Enrollments < Grape::API
      resource :enrollments do
        desc "invite a secondary parent"
        namespace :invite do
          before do
            authenticated
          end

          params do
            requires :email, type: String
            requires :first_name, type: String
            requires :last_name, type: String
          end

          post do
            error!({error_code: 422, error_message: 'E-mail is not available.'}) if email_taken?(params[:email])
            onboarding_group = OnboardingGroup.find_by_group_name(:invited_secondary_guardian)
            user = User.new(declared(params).merge(
              role: Role.guardian,
              family_id: current_user.family_id,
              vendor_id: generate_vendor_id,
              onboarding_group: onboarding_group
            ))
            if user.save validate: false
              InviteParentJob.send(user, current_user)
              present :onboarding_group, user.onboarding_group.group_name
            else
              error!({ error_code: 422, error_message: user.errors.full_messages }, 422)
            end
          end
        end

        desc "show an enrollment record"
        params do
          requires :authentication_token, type: String, allow_blank: false
        end

        get :current do
          session = Session.find_by_authentication_token params[:authentication_token]
          present session: { authentication_token: session.authentication_token }
          present :user, session.user, with: Leo::Entities::UserEntity
        end

        desc "create an enrollment"
        params do
          requires :email, type: String
          requires :password, type: String
          requires :vendor_id, type: String

          optional :device_token, type: String
          optional :device_type, type: String
          optional :client_platform, type: String
          optional :client_version, type: String
        end

        post do
          error!({error_code: 422, error_message: 'E-mail is not available.'}) if email_taken?(params[:email])

          declared_params = declared(params)
          session_keys = [:device_token, :device_type, :client_platform, :client_version]
          session_params = declared_params.extract(*session_keys)
          user_params = declared_params.except(*session_keys).merge({ role: Role.guardian })
          user = User.new user_params

          if user.save validate: false
            session = user.sessions.create session_params
            present session: { authentication_token: session.authentication_token }
            present :user, session.user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, error_message: user.errors.full_messages }, 422)
          end
        end

        desc "update an enrollment"
        params do
          requires :authentication_token, type: String, allow_blank: false
          optional :password, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :email, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :stripe_customer_id, type: String
          optional :phone, type: String
          optional :insurance_plan_id, type: Integer
        end

        put :current do
          error!({error_code: 422, error_message: 'E-mail is not available.'}) if email_taken?(params[:email])
          user_params = declared(params, include_missing: false).except(:authentication_token)
          if current_user.update_attributes user_params
            present session: { authentication_token: params[:authentication_token] }
            present :user, current_user, with: Leo::Entities::UserEntity
            ask_primary_guardian_approval if current_user.onboarding_group.try(:invited_secondary_guardian?)
          else
            error!({error_code: 422, error_message: current_user.errors.full_messages }, 422)
          end
        end
      end

      helpers do
        def ask_primary_guardian_approval
          primary_guardian = current_user.family.primary_guardian
          PrimaryGuardianApproveInvitationJob.send(primary_guardian, current_user)
        end

        def email_taken?(email)
          !!User.complete.find_by_email(email)
        end
      end
    end
  end
end
