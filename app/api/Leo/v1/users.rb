module Leo
  module V1
    class Users < Grape::API
      include Grape::Kaminari

      desc 'return all the staff'
      namespace :staff do
        before do
          authenticated
        end

        get do
          users = User.staff
          authorize! :read, User
          present :staff, users, with: Leo::Entities::UserEntity
        end
      end

      desc 'return users with matched names'
      namespace :search_user do
        before do
          authenticated
        end

        params do
          requires :query, type: String, allow_blank: false
        end

        get do
          error!({error_code: 422, user_message: 'query must have at least two characters'}, 422) if params[:query].length < 2
          users = User.complete.search(params[:query])
          guardians = users.joins(:role).where(roles: {name: "guardian"})
          staff = users.joins(:role).where.not(roles: {name: "guardian"})
          patients = Patient.search(params[:query]).to_a
          patients.reject! { |patient| patient.family.incomplete? }
          present :guardians, guardians, with: Leo::Entities::ShortUserEntity
          present :staff, staff, with: Leo::Entities::ShortUserEntity
          present :patients, patients, with: Leo::Entities::ShortPatientEntity
        end
      end

      desc 'convert invited or exempted user to complete'
      namespace :convert_user do
        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :password, type: String
          optional :phone, type: String
          optional :email, type: String
          at_least_one_of :first_name, :last_name, :password, :phone
        end

        put do
          authenticate_user_with_invitation_token
          user = User.find_by(invitation_token: params[:invitation_token])
          if user.update_attributes(user_params)
            if user.onboarding_group.try(:invited_secondary_guardian?)
              ask_primary_guardian_approval
            elsif user.onboarding_group.try(:generated_from_athena?)
              user.set_complete!
            end
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
          end
        end
      end

      resource :users do
        desc "confirm user's email address"
        namespace :confirm_email do
          params do
            requires :token, type: String
          end

          get do
            if user = User.find_by(confirmation_token: params[:token])
              user.confirm
              redirect "#{ENV['PROVIDER_APP_HOST']}/email/success", permanent: true
            else
              redirect "#{ENV['PROVIDER_APP_HOST']}/404", permanent: true
            end
          end
        end

        desc "confirm secondary guardian account"
        namespace :confirm_secondary_guardian do
          params do
            requires :invitation_token, type: String
          end

          before do
            authenticated
          end

          put do
            invited_user = current_user
            if user.invited_user? && user.confirm_secondary_guardian
              user.sessions.destroy_all
              present :user, user, with: Leo::Entities::UserEntity
            else
              error!({error_code: 422, user_message: user.errors.full_messages.first}, 422)
            end
          end
        end

        desc 'create user'
        params do
          requires :email, type: String
          requires :password, type: String
          requires :vendor_id, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :phone, type: String
          optional :sex, type: String, values: ['M', 'F']
          optional :device_type, type: String
          optional :os_version, type: String
          optional :platform, type: String
          optional :client_version, type: String
          optional :device_token, type: String
        end

        post do
          declared_params = declared params, include_missing: false
          session_keys = [:device_token, :device_type, :os_version, :platform, :client_version]
          user_params = declared_params.except(*session_keys)
          user_params = user_params.merge(
            role: Role.guardian,
            onboarding_group: OnboardingGroup.primary_guardian
          )

          if (user = User.create user_params) && user.valid?
            session = user.sessions.create(declared_params.slice(*session_keys))
            present :user, user, with: Leo::Entities::UserEntity
            present :session, session, with: Leo::Entities::SessionEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first}, 422)
          end
        end

        desc 'update user(DEPRECATED: only for ios backward-compatability)'
        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :phone, type: String
          optional :sex, type: String, values: ['M', 'F']
          at_least_one_of :first_name, :last_name, :phone, :sex
        end

        put do
          authenticated
          if user = current_user && user.update_attributes(declared(params, include_missing: false))
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
          end
        end

        namespace "current" do
          desc 'update current user'
          params do
            optional :first_name, type: String
            optional :last_name, type: String
            optional :phone, type: String
            optional :sex, type: String, values: ['M', 'F']
            at_least_one_of :first_name, :last_name, :phone, :sex
          end

          put do
            authenticated
            if user = current_user && user.update_attributes(declared(params, include_missing: false))
              present :user, user, with: Leo::Entities::UserEntity
            else
              error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
            end
          end

          desc 'fetch current user(guardian, invited, exempted)'
          params do
            optional :authentication_token, type: String
            optional :invitation_token, type: String
            mutually_exclusive :invitation_token, :authentication_token
            at_least_one_of :invitation_token, :authentication_token
          end

          get do
            if params[:authentication_token]
              authenticated
            else
              authenticate_user_with_invitation_token
              current_user = User.find_by(invitation_token: params[:invitation_token])
            end
            present :user, current_user, with: Leo::Entities::UserEntity
          end
        end

        route_param :id do
          before do
            authenticated
          end

          after_validation do
            @user = User.find(params[:id])
          end

          desc "#show get an individual user"
          get do
            authorize! :show, @user
            present :user, @user, with: Leo::Entities::UserEntity
          end

          desc "#put update individual user"
          params do
            requires :email, type: String, allow_blank: false
          end

          put do
            authorize! :update, @user
            user_params = declared(params)
            update_success @user, user_params, "User"
          end
        end
      end

      helpers do
        def ask_primary_guardian_approval(invited_guardian)
          if primary_guardian = invited_guardian.family.try(:primary_guardian)
            PrimaryGuardianApproveInvitationJob.send(primary_guardian.id, current_user.id)
          end
        end
      end
    end
  end
end
