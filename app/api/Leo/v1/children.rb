module Leo
  module V1
    class Children < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

      resource :children do
        desc "#get get all children of individual user"
        get do
          if @user != current_user
            error!({error_code: 403, error_message: "You don't have permission to list this user's children."}, 403)
            return
          end
          children = @user.family.children
          present :children, children, with: Leo::Entities::UserEntity
        end

        desc "#post create a child for this user"
        params do
          requires :first_name, type: String, desc: "First Name"
          requires :last_name,  type: String, desc: "Last Name"
          optional :email,      type: String, desc: "Email"
          requires :dob,        type: String, desc: "Date of Birth"
          requires :sex,        type: String, desc: "Sex", values: ['M', 'F']
        end

        post do
          if @user != current_user
            error!({error_code: 403, error_message: "You don't have permission to add a child for this user."}, 403)
            return
          end
          # Check that date makes sense
          dob = Chronic.try(:parse, params[:dob])
          if params[:dob].strip.length > 0 and dob.nil?
            error!({error_code: 422, error_message: "Invalid dob format"},422)
            return
          end

          family = @user.family
          child_params = { first_name: params[:first_name],
                           last_name: params[:last_name],
                           email: params[:email],
                           dob: dob,
                           family_id: family.id,
                           sex: params[:sex] }

          if child = User.create(child_params)
            child.add_role :patient
            child.save!
          end
          present :user, child, with: Leo::Entities::UserEntity
        end
      end
    end
  end
end
