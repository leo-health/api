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

        desc "invite a secondary guardian"
        namespace :invite do
          params do
            requires :email, type: String
            requires :first_name, type: String
            requires :last_name, type: String
          end

          post do
            user_to_invite = User.new(declared(params).merge(
              role: Role.guardian,
              family: current_user.family,
              invitation_token: GenericHelper.generate_token(:invitation_token),
              vendor_id: GenericHelper.generate_token(:vendor_id),
              onboarding_group: OnboardingGroup.invited_secondary_guardian
            ))

            if user_to_invite.save
              InviteParentJob.send(user_to_invite.id, current_user.id)
              present user_to_invite, with: Leo::Entities::UserEntity
            else
              error!({ error_code: 422, user_message: user_to_invite.errors.full_messages.first }, 422)
            end
          end
        end
      end
    end
  end
end
