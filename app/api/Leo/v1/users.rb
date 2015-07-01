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
          authenticated_user
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
          requires :role,       type: String, role_exists: true
          requires :dob,        type: String, allow_blank: false
          requires :gender,     type: String, values: ['M', 'F']
        end

        post do
          dob = Chronic.try(:parse, params[:dob])
          unless dob
            error!({error_code: 422, error_message: "unprocessable entity"},422) and return
          end

          role = Role.where(name: params[:role])
          family = Family.create!
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
            auth_token = session.authentication_token
            present user, with: Leo::Entities::UserWithAuthEntity
          end
        end

        route_param :id do
          before do
            authenticated_user
          end

          after_validation do
            @user = User.find(params[:id])
          end

          desc "#show get an individual user"
          get do
            present @user, with: Leo::Entities::UserEntity
          end

          desc "#put update individual user"
          params do
            optional :email, type: String, allow_blank: false
          end

          put do
            user_params = declared(params)
            if @user.update_attributes(user_params)
              present @user, with: Leo::Entities::UserEntity
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

          namespace :children do
            # GET users/:id/children
            desc "#get get all children of individual user"
            get do
              if @user != current_user
                error!({error_code: 403, error_message: "You don't have permission to list this user's children."}, 403)
                return
              end
              children = @user.family.children
              present :children, children, with: Leo::Entities::UserEntity
            end

            # POST users/:id/children
            desc "#post create a child for this user"
            params do
              requires :first_name, type: String, desc: "First Name"
              requires :last_name,  type: String, desc: "Last Name"
              optional :email,      type: String, desc: "Email"
              requires :dob,        type: String, desc: "Date of Birth"
              requires :sex,        type: String, desc: "Sex", values: ['M', 'F', 'U']
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
                child.add_role :child
                child.save!
              end
              present :user, child, with: Leo::Entities::UserEntity
            end
          end
        end
      end
    end
  end
end
