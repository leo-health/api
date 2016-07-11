module Leo
  module V1
    class Families < Grape::API
      include Grape::Kaminari

      resource :family do
        before do
          authenticated
        end

        namespace :patients do
          params do
            requires :patients, type: Array do
              requires :first_name, type: String, allow_blank: false
              requires :last_name, type: String, allow_blank: false
              requires :birth_date, type: Date, allow_blank: false
              requires :sex, type: String, values: ['M', 'F']
              optional :title, type: String
              optional :suffix, type: String
              optional :middle_initial, type: String
              optional :email, type: String
            end
          end

          post do
            authorize! :create, Patient
            patients_params = declared(params, include_missing: false)[:patients]
            patients = []
            Patient.transaction do
              patients = patients_params.map { |patient_params|
                current_user.family.patients.update_or_create!([:first_name, :last_name, :birth_date], patient_params)
              }
              current_user.family.update_or_create_stripe_subscription_if_needed!
            end
            present :patients, patients, with: Leo::Entities::PatientEntity
          end
        end

        desc "Return the family and members of current user"
        get  do
          if current_user.has_role? :guardian
            render_success current_user.family, session_device_type
          else
            error!({error_code: 422, user_message: "Current user is not a guardian"}, 422)
          end
        end

        desc "invite a secondary parent"
        namespace :invite do
          params do
            requires :email, type: String
            requires :first_name, type: String
            requires :last_name, type: String
          end

          post do
            error!({error_code: 422, user_message: 'E-mail is not available.'}) if User.email_taken?(params[:email])
            onboarding_group = OnboardingGroup.invited_secondary_guardian
            user = User.new(declared(params).merge(
              role: Role.guardian,
              family_id: current_user.family_id,
              vendor_id: GenericHelper.generate_vendor_id,
              onboarding_group: onboarding_group
            ))
            if user.save
              InviteParentJob.send(user, current_user)
              present :onboarding_group, user.onboarding_group.group_name
            else
              error!({ error_code: 422, user_message: user.errors.full_messages.first }, 422)
            end
          end
        end
      end
    end
  end
end
