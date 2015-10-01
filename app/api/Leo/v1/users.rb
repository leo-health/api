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
        post do
          enrollment = Enrollment.find_by_authentication_token(params[:authentication_token])
          error!({error_code: 401, error_message: '401 Unauthorized' }, 401) unless enrollment
          user_params = {
            first_name: enrollment.first_name,
            last_name: enrollment.last_name,
            email: enrollment.email,
            birth_date: enrollment.birth_date,
            sex: enrollment.sex,
            encrypted_password: enrollment.encrypted_password,
            title: enrollment.title,
            suffix: enrollment.suffix,
            phone_number: enrollment.phone_number,
            middle_initial: enrollment.middle_initial,
            stripe_customer_id: enrollment.stripe_customer_id,
            role_id: 4
          }
          ActiveRecord::Base.transaction do
            begin
              family = Family.create!
              user = User.create!( user_params.merge(family: family) )
              enrollment.patient_enrollments.each do|patient_enrollment|
                patient_enrollment_params = patient_enrollment.attributes.merge(family: user.family)
                patient = Patient.create!(patient_enrollment_params.except('guardian_enrollment_id', 'id', 'created_at', 'updated_at'))
                if insurance_plan = enrollment.insurance_plan
                  patient.insurances.create(plan_name: insurance_plan.plan_name, primay: 1)
                end
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
