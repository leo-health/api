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
          users = User.includes(:role).where.not(roles: {name: :guardian})
          authorize! :read, User
          present :staff, users, with: Leo::Entities::UserEntity
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
        end

        post do
          user = User.new(declared(params, include_missing: false).merge({role_id: 4}))
          if user.save
            session = user.sessions.create
            present :authentication_token, session.authentication_token
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, error_message: user.errors.full_messages }, 422)
          end
        end
      end

      resource :users do
        desc '#create user from enrollment'
        params do
          requires :authentication_token, type: String, allow_blank: false
          requires :guardian, type: Hash do
            requires :first_name, type: String
            requires :last_name, type: String
            requires :phone, type: String
            optional :birth_date, type: Date
            optional :sex, type: String, values: ['M', 'F']
            optional :middle_initial, type: String
          end

          requires :patients, type: Array do
            requires :first_name, type: String
            requires :last_name, type: String
            requires :birth_date, type: Date
            requires :sex, type: String, values: ['M', 'F']
            optional :birth_date, type: Date
            optional :middle_initial, type: String
          end

          requires :insurance_plan, type: Hash do
            requires :id, type: Integer
          end
        end

        post do
          ActiveRecord::Base.transaction do
            begin
              declared_params = declared(params)
              enrollment = Enrollment.find_by_authentication_token!(params[:authentication_token])
              family = Family.create!
              user = User.create!( declared_params[:guardian].merge(family: family, role_id: 4, encrypted_password: enrollment.encrypted_password, email: enrollment.email) )
              insurance_plan = InsurancePlan.find(params[:insurance_plan][:id])
              insurance_params = { primary: 1,
                                   plan_name: insurance_plan.plan_name,
                                   holder_first_name: user.first_name,
                                   holder_last_name: user.last_name,
                                   holder_sex: user.sex
              }
              declared_params[:patients].each do |patient_param|
                patient = family.patients.create!(patient_param)
                patient.insurances.create!(insurance_params)
              end
              session = user.sessions.create
              present :authentication_token, session.authentication_token
              present :patients, family.patients, with: Leo::Entities::PatientEntity
              present :user, user, with: Leo::Entities::UserEntity
            rescue ActiveRecord::RecordInvalid => e
              error!({error_code: 422, error_message: e.message }, 422)
            rescue
              error!({error_code: 500, error_message: "can't create guardian with patients" }, 500)
            end
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

          desc '#delete destroy a user, super user only'
          delete do
            authorize! :destroy, @user
            @user.try(:destroy)
          end
        end
      end
    end
  end
end
