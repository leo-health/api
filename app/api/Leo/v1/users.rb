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
            redirect "#{ENV['PROVIDER_APP_HOST']}/#/success", permanent: true
          else
            redirect "#{ENV['PROVIDER_APP_HOST']}/#/404", permanent: true
          end
        end
      end

      resource :users do
        desc '#create user'
        params do
          optional :email, type: String
          optional :password, type: String
          optional :vendor_id, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :phone, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :middle_initial, type: String
          optional :title, type: String
          optional :suffix, type: String

          optional :device_token, type: String
          optional :device_type, type: String
          optional :os_version, type: String
          optional :client_platform, type: String
          optional :client_version, type: String
        end

        post do
          declared_params = declared params, include_missing: false
          session_keys = [:device_token, :device_type, :os_version, :client_platform, :client_version]
          session_params = declared_params.slice(*session_keys) || {}

          # TODO: user_params (all params?) should be required in versions > "1.0.0"
          user_params = (declared_params.except(*session_keys) || {}).merge({ role: Role.guardian })

          if (params[:client_version] || "0") >= "1.0.1"
            # NOTE: in the newer version,
            # this endpoint is used to create an incomplete user
            # instead of post enrollments
            user = User.new user_params
            if user.save
              session = user.sessions.create(session_params)
              present :user, user, with: Leo::Entities::UserEntity
              present :session, session, with: Leo::Entities::SessionEntity
            else
              error!({error_code: 422, user_message: user.errors.full_messages.first}, 422)
            end
          else
            authenticated
            # in the old version, this endpoint is used to
            # update an incomplete user after calling post enrollments
            user = current_user
            ActiveRecord::Base.transaction do
              update_success user, user_params, "User"
              user.family.exempt_membership!
            end
            if user.invited_user?
              error!({error_code: 422, user_message: user.errors.full_messages.first}, 422) unless user.confirm_secondary_guardian
            end
            session = Session.find_by_authentication_token(params[:authentication_token])
            update_success session, session_params
          end
        end

        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :phone, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :middle_initial, type: String
          optional :title, type: String
          optional :suffix, type: String
        end

        put do
          authenticated
          user = current_user
          user_params = declared(params)
          update_success user, user_params
        end

        get do
          authenticated
          present :user, current_user, with: Leo::Entities::UserEntity
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
    end
  end
end
