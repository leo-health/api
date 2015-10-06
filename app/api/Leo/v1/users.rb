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
          requires :birth_date, type: Date
          requires :phone_number, type: String
          requires :sex, type: String, values: ['M', 'F']
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
          requires :user_params, type: Hash do
            requires :first_name, type: String
            requires :last_name, type: String
            requires :email, type: String
            requires :password, type: String
            requires :birth_date, type: Date
            requires :phone_number, type: String
            requires :sex, type: String, values: ['M', 'F']
          end

          requires :patient_params, type: Array do
            requires :patient, type: Hash do
              requires :first_name, type: String
              requires :last_name, type: String
              requires :birth_date, type: Date
              requires :sex, type: String, values: ['M', 'F']
            end
            requires :insurance, type: Hash do
              requires :plan_name, type: String
            end
          end
        end

        post do
          ActiveRecord::Base.transaction do
            begin
              family = Family.create!
              user = User.create!( params[:user_params].merge(family: family, role_id: 4) )
              params[:patient_params].each do |patient_param|
                patient = family.patients.create!(patient_param[:patient])
                patient.insurances.create!(patient_param[:insurance].merge(primary: 1))
              end
              session = user.sessions.create
              present :authentication_token, session.authentication_token
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
          get do
            authorize! :show, @user
            present :user, @user, with: Leo::Entities::UserEntity
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
