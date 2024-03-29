module Leo
  module V1
    class StaffProfiles < Grape::API
      resources :staff_profiles do
        before do
          authenticated
          error!('401 Unauthorized', 401) if current_user.guardian?
        end

        desc 'update staff profile(PUT /api/v1/staff_profiles/current)'
        params do
          optional :sms_enabled, type: Boolean
          optional :on_call, type: Boolean
        end

        put :current do
          declared_params = declared params, include_missing: false
          if (staff_profile = current_user.staff_profile) && staff_profile.update_attributes(declared_params)
            present :user, staff_profile.staff, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, user_message: staff_profile.errors.full_messages.first }, 422)
          end
        end
      end
    end
  end
end
