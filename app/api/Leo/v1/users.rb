module Leo
  module V1
    class Users < Grape::API
      include Grape::Kaminari

      desc '#return all the staff'
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

      desc "confirm user's email address"
      namespace "users/confirm_email" do
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
      namespace "users/confirm_secondary_guardian" do
        params do
          requires :authentication_token, type: String
        end

        before do
          authenticated
        end

        put do
          user = current_user
          if user.invited_user? && user.confirm_secondary_guardian
            user.sessions.destroy_all
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first}, 422)
          end
        end
      end

      resource :users do
        desc '#create user'
        params do
          requires :email, type: String
          requires :password, type: String
          requires :vendor_id, type: String
          requires :first_name, type: String
          requires :last_name, type: String
          requires :phone, type: String
          requires :sex, type: String, values: ['M', 'F']
          requires :device_type, type: String
          requires :os_version, type: String
          requires :client_platform, type: String
          optional :client_version, type: String
          optional :birth_date, type: Date
          optional :middle_initial, type: String
          optional :title, type: String
          optional :suffix, type: String
          optional :device_token, type: String
        end

        post do
          declared_params = declared params, include_missing: false
          session_keys = [:device_token, :device_type, :os_version, :client_platform, :client_version]
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

        params do
          requires :authentication_token, type: String, allow_blank: false
          optional :first_name, type: String
          optional :last_name, type: String
          optional :password, type: String
          optional :phone, type: String
          optional :email, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :title, type: String
          at_least_one_of :first_name, :last_name, :password, :phone, :birth_date, :sex, :title
        end

        put do
          authenticated
          user_params = declared(params, include_missing: false).except(:authentication_token)
          user = current_user
          if user.update_attributes(user_params)
            if onboarding_group = user.onboarding_group
              if onboarding_group.invited_secondary_guardian?
                ask_primary_guardian_approval
                current_session.destroy
              end

              if onboarding_group.generated_from_athena?
                user.set_complete!
                current_session.destroy
                session = user.create_onboarding_session
                present :session, session, with: Leo::Entities::SessionEntity
              end
            end
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
          end
        end

        get do
          authenticated
          present :user, current_user, with: Leo::Entities::UserEntity
        end

        # Duplicated until front ends use the same endpoint
        namespace "users/current" do
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
            at_least_one_of :first_name, :last_name, :password, :phone, :birth_date, :sex, :title
          end

          put do
            authenticated
            user_params = declared(params, include_missing: false).except(:authentication_token)
            user = current_user
            if user.update_attributes(user_params)
              if onboarding_group = user.onboarding_group
                if onboarding_group.invited_secondary_guardian?
                  ask_primary_guardian_approval
                  current_session.destroy
                end

                if onboarding_group.generated_from_athena?
                  user.set_complete!
                  current_session.destroy
                  session = user.sessions.create
                  present :session, session, with: Leo::Entities::SessionEntity
                end
              end
              present :user, user, with: Leo::Entities::UserEntity
            else
              error!({error_code: 422, user_message: user.errors.full_messages.first }, 422)
            end
          end

          get do
            authenticated
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
        def ask_primary_guardian_approval
          primary_guardian = current_user.family.primary_guardian
          PrimaryGuardianApproveInvitationJob.send(primary_guardian, current_user)
        end
      end
    end
  end
end
