module Leo
  module V1
    class Users < Grape::API
      include Grape::Kaminari

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
          requires :first_name, type: String
          requires :last_name, type: String
          requires :email, type: String
          requires :password, type: String
          requires :birth_date, type: Date
          requires :sex, type: String, values: ['M', 'F']
          optional :family_id, type: Integer
        end

        post do
          user = User.new(declared(params, include_missing: false).merge({role_id: 4}))
          if user.save
            session = user.sessions.create
            present :authentication_token, session.authentication_token
            present :user, user, with: Leo::Entities::UserEntity
          else
            byebug
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
