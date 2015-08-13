module Leo
  module V1
    class Users < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

      resource :users do

        desc "Get available users by role"
        paginate per_page: 20
        params do
          requires :role, type: String, allow_blank: false
        end
        get do
          authenticated
          users = User.where(role_id: Role.find_by_name(params[:name].id))
          present :users, paginate(users), with: Leo::Entities::UserEntity
        end

        desc "#post create a user"
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name,  type: String, allow_blank: false
          requires :email,      type: String, allow_blank: false
          requires :password,   type: String, allow_blank: false
          requires :role_id,    type: Integer, allow_blank: false, role_exists: true
          requires :dob,        type: DateTime, allow_blank: false
          requires :sex,        type: String, values: ['M', 'F']
          optional :family_id,  type: Integer, allow_blank: false
        end

        post do
          user = User.new(declared(params))
          if user.save
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
