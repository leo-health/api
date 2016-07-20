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
            user_to_invite = User.new(declared(params).merge(
              role: Role.guardian,
              family: current_user.family,
              onboarding_group: OnboardingGroup.invited_secondary_guardian
            ))

            if user_to_invite.save
              InviteParentJob.send(user_to_invite.id, current_user.id)
              user_to_invite.update_attributes(invitation_sent_at: Time.now)
              present user_to_invite, with: Leo::Entities::UserEntity
            else
              error!({ error_code: 422, user_message: user_to_invite.errors.full_messages.first }, 422)
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
          optional :platform, type: String
          optional :client_version, type: String
        end

        post do
          session_keys = [:device_token, :device_type, :os_version, :platform, :client_version]
          session_params = declared(params).slice(*session_keys)
          user_params = (declared(params).except(*session_keys) || {}).merge(
            role: Role.guardian,
            onboarding_group: OnboardingGroup.primary_guardian
          )
          user = User.new user_params
          if user.save
            session = user.sessions.create(session_params)
            present session: { authentication_token: session.authentication_token }
            present :user, session.user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
          end
        end
      end
    end
  end
end
