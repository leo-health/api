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
          present :guardians, guardians, with: Leo::Entities::ShortUserEntity
          present :staff, staff, with: Leo::Entities::ShortUserEntity
          present :patients, patients, with: Leo::Entities::ShortPatientEntity
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
          create_success user
          session = user.sessions.create
          present :session, session
        end
      end

      resource :users do
        desc '#create user from enrollment'
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

        post do
          enrollment = Enrollment.find_by_authentication_token!(params[:authentication_token])

          error!({error_code: 401, error_message: "Invalid Token" }, 401) unless enrollment
          enrollment_params = { encrypted_password: enrollment.encrypted_password,
                                email: enrollment.email,
                                first_name: enrollment.first_name,
                                last_name: enrollment.last_name,
                                phone: enrollment.phone,
                                onboarding_group: enrollment.onboarding_group,
                                role_id: enrollment.role_id,
                                family_id: enrollment.family_id,
                                birth_date: enrollment.birth_date,
                                sex: enrollment.sex,
                                insurance_plan_id: enrollment.insurance_plan_id
                              }

          user = User.new(enrollment_params.merge!(declared(params, include_missing: false)))
          create_success user
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
          get do
            authorize! :show, @user
            render_success @user
          end

          desc "#put update individual user"
          params do
            requires :email, type: String, allow_blank: false
          end

          put do
            user_params = declared(params)
            update_success @user, user_params
          end
        end

        desc "confirm user's email address"
        namespace "/confirm_email" do
          params do
            requires :token, type: String
          end

          post do
            user = User.find_by!(confirmation_token: params[:token])
            if user.confirm
              redirect "#{ENV['PROVIDER_APP_HOST']}/#/success", permanent: true
            end
          end
        end
      end
    end
  end
end
