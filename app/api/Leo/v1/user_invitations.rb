module Leo
  module V1
    class UserInvitations < Grape::API
      include Grape::Kaminari

      resource :invitations do
        # GET users/:id/invitations
        desc "Get invitations sent by this user"
        get do
          if @user != current_user
            error!({error_code: 403, error_message: "You don't have permission to list this user's invitiations."}, 403)
            return
          end
          invitations = @user.invitations
          present :invitations, invitations, with: Leo::Entities::UserEntity
        end

        # POST users/:id/invitations
        desc "Invite a parent"
        params do
          requires :first_name, type: String, desc: "First Name"
          requires :last_name,  type: String, desc: "Last Name"
          requires :email,      type: String, desc: "Email"
          requires :dob,        type: String, desc: "Date of Birth"
          requires :sex,        type: String, desc: "Sex", values: ['M', 'F']
        end
        post do
          if @user != current_user
            error!({error_code: 403, error_message: "You don't have permission to list this user's invitiations."}, 403)
            return
          end
          # Check that date makes sense
          dob = Chronic.try(:parse, params[:dob])
          if params[:dob].strip.length > 0 and dob.nil?
            error!({error_code: 422, error_message: "Invalid dob format"},422)
            return
          end

          family = Family.find(@user.family_id)
          invited_user = User.invite!(
              email:        params[:email],
              first_name:   params[:first_name],
              last_name:    params[:last_name],
              dob:          dob,
              family_id:    @user.family_id,
              sex:          params[:sex]
          ) do |u|
            u.invited_by_id =  @user.id
            u.invited_by_type = 'User'
          end

          invited_user.add_role :guardian
          family.conversation.participants << invited_user
          present :user, invited_user, with: Leo::Entities::UserEntity
        end

        # DELETE users/:id/invitations/
        params do
          requires :user_id,         type: Integer, desc: "Id for user who's invitation is to be deleted"
        end
        # delete do
        #   if @user != current_user
        #     error!({error_code: 403, error_message: "You don't have permission to delete this user's invitiations."}, 403)
        #     return
        #   end
        #   user_id = params[:user_id]
        #   user_to_delete = User.find_by_id(user_id)
        #   if user_id.blank? or user_to_delete.nil?
        #     error!({error_code: 422, error_message: "The user id is invalid."}, 422)
        #     return
        #   end
        #
        #   if !user_to_delete.invitation_accepted_at.nil? or user_to_delete.family.primary_parent.id != @user.id or user_to_delete == @user
        #     error!({error_code: 403, error_message: "You don't have permission to delete this invitation or it is no longer pending."}, 403)
        #     return
        #   end
        #   result = User.destroy(user_to_delete.id)
        # end
      end
    end
  end
end
