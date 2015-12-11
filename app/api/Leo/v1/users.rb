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
          error!({error_code: 422, error_message: 'query must have at least two characters'}, 422) if params[:query].length < 2
          users = User.search(params[:query])
          guardians = users.joins(:role).where(roles: {name: "guardian"})
          staff = users.joins(:role).where.not(roles: {name: "guardian"})
          patients = Patient.search(params[:query])
          present :guardians, guardians, with: Leo::Entities::UserEntity
          present :staff, staff, with: Leo::Entities::UserEntity
          present :patients, patients, with: Leo::Entities::PatientEntity
        end
      end

      desc "#post create a user with provided params"
      namespace :sign_up do
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :email, type: String
          requires :password, type: String
          requires :phone, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :family_id, type: Integer
          optional :middle_initial, type: String
          optional :title, type: String
          optional :suffix, type: String
        end

        post do
          user = User.new(declared(params, include_missing: false).merge({role_id: 4}))
          if user.save
            session = user.sessions.create
            present :session, session
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, error_message: user.errors.full_messages }, 422)
          end
        end
      end

      resource :users do
        desc '#create user from enrollment'
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :phone, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :middle_initial, type: String
          optional :title, type: String
          optional :suffix, type: String
        end

        post do
          enrollment = Enrollment.find_by_authentication_token!(params[:authentication_token])
          user = User.new(declared(params).merge(role_id: 4,
                                                 encrypted_password: enrollment.encrypted_password,
                                                 email: enrollment.email,
                                                 onboarding_group: enrollment.onboarding_group))

          render_success user
          session = user.sessions.create
          present :session, session
        end

        route_param :id do
          before do
            authenticated
          end

          after_validation do
            @user = User.find(params[:id])
          end

          desc "#show get an individual user"
          params do
            optional :avatar_size, type: String, values: ["primary_3x", "primary_2x", "primary_1x", "secondary_3x", "secondary_2x", "secondary_1x"]
          end

          get do
            authorize! :show, @user
            present :user, @user, with: Leo::Entities::UserEntity, avatar_size: params[:avatar_size].try(:to_sym)
          end

          desc "#put update individual user"
          params do
            requires :email, type: String, allow_blank: false
          end

          put do
            user_params = declared(params)
            if @user.update_attributes(user_params)
              present :user, @user, with: Leo::Entities::UserEntity
            end
          end
        end
      end
    end
  end
end
