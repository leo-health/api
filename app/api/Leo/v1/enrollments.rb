module Leo
  module V1
    class Enrollments < Grape::API
      resource :enrollments do
        desc "invite a secondary parent"
        namespace :invite do
          before do
            authenticated
          end

          params do
            requires :email, type: String
            requires :first_name, type: String
            requires :last_name, type: String
          end

          post do
            error!({error_code: 422, error_message: 'email is taken'}) if email_taken?(params[:email])
            onboarding_group = OnboardingGroup.find_by_group_name(:invited_secondary_guardian)
            enrollment = Enrollment.create(declared(params).merge( role_id: 4,
                                                                   family_id: current_user.family_id,
                                                                   invited_user: true,
                                                                   onboarding_group: onboarding_group ))

            if enrollment.valid?
              InviteParentJob.new(enrollment.id, current_user.id).send
              present :onboarding_group, enrollment.onboarding_group.group_name
            else
              error!({ error_code: 422, error_message: enrollment.errors.full_messages }, 422)
            end
          end
        end

        desc "show an enrollment record"
        params do
          requires :authentication_token, type: String, allow_blank: false
        end

        get :current do
          find_enrollment
          present_session(@enrollment)
        end

        desc "create an enrollment"
        params do
          requires :email, type: String
          requires :password, type: String
        end

        post do
          error!({error_code: 422, error_message: 'email is taken'}) if email_taken?(params[:email])
          enrollment = Enrollment.create(declared(params).merge({role_id: 4}))
          if enrollment.valid?
            present_session(enrollment)
          else
            error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422)
          end
        end

        desc "update an enrollment"
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
        end

        put :current do
          error!({error_code: 422, error_message: 'email is taken'}) if email_taken?(params[:email])
          find_enrollment
          if @enrollment.update_attributes(declared(params, include_missing: false))
            present_session(@enrollment)
            ask_primary_guardian_approval if @enrollment.onboarding_group.try(:invited_secondary_guardian?)
          else
            error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422)
          end
        end
      end

      helpers do
        def find_enrollment
          @enrollment = Enrollment.find_by_authentication_token(params[:authentication_token])
          error!({ error_code: 401, error_message: '401 Unauthorized' }, 401) unless @enrollment
          @enrollment
        end

        def ask_primary_guardian_approval
          @enrollment.update_attributes(authentication_token: nil)
          primary_guardian = @enrollment.family.primary_parent
          UserMailer.delay.primary_guardian_approve_invitation(primary_guardian, @enrollment.authentication_token)
        end

        def email_taken?(email)
          !!User.find_by_email(email)
        end

        def present_session(enrollment)
          present session: { authentication_token: enrollment.authentication_token }
          present :user, enrollment, with: Leo::Entities::EnrollmentEntity
        end
      end
    end
  end
end
