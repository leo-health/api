module Leo
  module V1
    class Families < Grape::API
      include Grape::Kaminari

      resource :family do
        before do
          authenticated
        end

        desc "Return the family and members of current user"
        get  do
          if current_user.has_role? :guardian
            render_success current_user.family, session_device_type
          else
            error!({error_code: 422, error_message: "Current user is not a guardian"}, 422)
          end
        end

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
            error!({error_code: 422, error_message: 'E-mail is not available.'}) if User.email_taken?(params[:email])
            onboarding_group = OnboardingGroup.find_by_group_name(:invited_secondary_guardian)
            user = User.new(declared(params).merge(
              role: Role.guardian,
              family_id: current_user.family_id,
              vendor_id: GenericHelper.generate_vendor_id,
              onboarding_group: onboarding_group
            ))
            if user.save
              user.sessions.create
              InviteParentJob.send(user, current_user)
              present :onboarding_group, user.onboarding_group.group_name
            else
              error!({ error_code: 422, error_message: user.errors.full_messages.first }, 422)
            end
          end
        end
      end
    end
  end
end
