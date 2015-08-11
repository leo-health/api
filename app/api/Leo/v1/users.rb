module Leo
  module V1
    class Users < Grape::API
      include Grape::Kaminari

      resource :users do
        desc "Get available users"
        paginate per_page: 20
        params do
          optional :role,     type: String,   desc: "Return users with this role"
        end
        get do
          authenticated
          users = User.for_user(current_user)

          unless params[:role].blank?
            role=Role.find_by_name(params[:role])
            if role.nil?
              error!({error_code: 422, error_message: "Invalid role."}, 422)
              return
            end
            users = users.with_role role.name.to_sym
          end

          present :users, paginate(users), with: Leo::Entities::UserEntity
        end

        desc "#post create a user"
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name,  type: String, allow_blank: false
          requires :email,      type: String, allow_blank: false
          requires :password,   type: String, allow_blank: false
          requires :role_id,    type: Integer, allow_blank: false, role_exists: true
          requires :dob,        type: String, allow_blank: false
          requires :sex,        type: String, values: ['M', 'F']
          optional :family_id,  type: Integer, allow_blank: false
        end

        post do
          dob = Chronic.try(:parse, params[:dob])
          role = Role.find(params[:role_id])
          user_params = { first_name: params[:first_name],
                          last_name: params[:last_name],
                          email: params[:email],
                          password: params[:password],
                          dob: dob,
                          sex: params[:sex] }

          if role.name == "guardian"
            family = params[:family_id] ? Family.find(params[:family_id]) : Family.create!
            user_params.merge!(family_id: family.id)
          end

          user = User.new(user_params)
          if user.save
            user.roles << role
            session = user.sessions.create
            present :authentication_token, session.authentication_token
            present :user, user, with: Leo::Entities::UserEntity
          else
            error!({error_code: 422, error_message: user.errors.full_messages }, 422)
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
            present :user, @user, with: Leo::Entities::UserEntity
          end

          desc "#put update individual user"
          params do
            optional :email, type: String, allow_blank: false
          end

          put do
            user_params = declared(params)
            if @user.update_attributes(user_params)
              present :user, @user, with: Leo::Entities::UserEntity
            end
          end

          desc '#delete destroy a user, super user only'
          delete do
            user = User.find(params[:id])
            authorize! :destroy, user
            user.try(:destroy)
          end
        end
      end
    end
  end
end
