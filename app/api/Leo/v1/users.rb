module Leo
  module V1
    class Users < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

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
          requires :gender,     type: String, values: ['M', 'F']
          optional :family_id,  type: Integer, allow_blank: false
        end

        post do
          dob = Chronic.try(:parse, params[:dob])
          role = Role.find(params[:role_id])
          family = params[:family_id] ? Family.find(params[:family_id]) : Family.create!

          unless family && dob && role
            error!({error_code: 422, error_message: "unprocessable entity"},422) and return
          end

          user_params = { first_name: params[:first_name],
                          last_name: params[:last_name],
                          email: params[:email],
                          password: params[:password],
                          dob: dob,
                          family_id: family.id,
                          gender: params[:gender] }

          if user = User.create(user_params)
            user.roles << role
            family.conversation.participants << user
            session = user.sessions.create
            present :authentication_token, session.authentication_token
            present :user, user, with: Leo::Entities::UserEntity
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
            else
              error!({errors: @user.errors.messages})
            end
          end

          desc 'delete a user with admin right'
          delete do
            error!({error_code: 422}, 422) unless current_user.has_role? :admin
            user = User.find(params[:id])
            user.try(:destroy)
          end
        end
      end
    end
  end
end
