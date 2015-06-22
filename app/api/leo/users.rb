module Leo
  module Entities
    class UserEntity < Grape::Entity
      expose :id
      expose :title
      expose :first_name
      expose :middle_initial
      expose :last_name
      expose :dob
      expose :sex
      expose :practice_id
      expose :family_id
      expose :email
      expose :primary_role
      expose :stripe_customer_id
    end 

    class UserWithAuthEntity < UserEntity
      expose :authentication_token
    end

    class RoleEntity < Grape::Entity
      expose :id
      expose :name
    end
  end

  class Users < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    include Grape::Kaminari

    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter

    resource :roles do
      desc "Return all roles"
      get "/" do 
        puts "In get roles"
        present :roles, Role.all, with: Leo::Entities::RoleEntity
      end
    end

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
        requires :first_name, type: String, desc: "First Name"
        requires :last_name,  type: String, desc: "Last Name"
        requires :email,      type: String, desc: "Email", user_unique: true
        requires :password,   type: String, desc: "Password"
        requires :role,       type: String, desc: "Role for the user. Get list from /roles", role_exists: true
        requires :dob,        type: String, desc: "Date of Birth"
        requires :sex,        type: String, desc: "Sex", values: ['M', 'F', 'U']
      end

      post do
        dob = Chronic.try(:parse, params[:dob])
        unless dob
          error!({error_code: 422, error_message: "Invalid dob format"},422) and return
        end

        role = Role.where(name: params[:role])
        family = Family.create!
        user_params = { first_name: params[:first_name],
                        last_name: params[:last_name],
                        email: params[:email],
                        password: params[:password],
                        dob: dob,
                        family_id: family.id,
                        sex: params[:sex] }

        if user = User.create(user_params)
          user.roles << role
          family.conversation.participants << user
          user.ensure_authentication_token
          present :user, user, with: Leo::Entities::UserWithAuthEntity
        end
        #here just creating user, why assign user the auth_token? or say what is the use case here?
      end

      desc "single user methods"
      route_param :id do 
        before do
          authenticated_user
        end

        after_validation do
          @user = User.find(params[:id])
        end

        desc "#show individual user"
        params do
          requires :id, type:String, allow_blank: false
        end

        get do
          present :user, @user, with: Leo::Entities::UserEntity
        end

        desc "add credit card for individual user"
        params do
          requires :stripe_token,  type: String, desc: "Stripe Token to use for creating Stripe token"
        end
        #extract the stripe part out later from users api
        post "/add_card" do
          token = params[:stripe_token]
          unless token || token.blank?
            error!({error_code: 422, error_message: "A valid stripe token is required."}, 422) and return
          end
          # Save the customer ID in user table so you can use it later
          @user.create_or_update_stripe_customer_id(token)
          present :user, @user, with: Leo::Entities::UserEntity
        end

        desc "#update individual user information"
        params do
          optional :email,      type: String, desc: "Email"
        end

        put do
          user_params = declared(params)
          if @user.update_attributes(user_params)
            present :user, @user, with: Leo::Entities::UserEntity
          else
            error!({errors: @user.errors.messages})
          end
        end
        
        namespace :invitations do

          # GET users/:id/invitations
          desc "Get invitations sent by this user"
          get do
            puts "In get /users/#{params[:id]}/invitations"
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
            requires :email,      type: String, desc: "Email", user_unique: true
            requires :dob,        type: String, desc: "Date of Birth"
            requires :sex,        type: String, desc: "Sex", values: ['M', 'F', 'U']
          end
          post do
            puts "In post /users/#{params[:id]}/invitations"
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
            
            invited_user.add_role :parent
            family.conversation.participants << invited_user
            present :user, invited_user, with: Leo::Entities::UserEntity
          end

          # DELETE users/:id/invitations/
          params do
            requires :user_id,         type: Integer, desc: "Id for user who's invitation is to be deleted"
          end
          delete do
            puts "In DELETE /users/#{params[:id]}/invitations"
            if @user != current_user
              error!({error_code: 403, error_message: "You don't have permission to delete this user's invitiations."}, 403)
              return
            end
            user_id = params[:user_id]
            user_to_delete = User.find_by_id(user_id)
            if user_id.blank? or user_to_delete.nil?
              error!({error_code: 422, error_message: "The user id is invalid."}, 422)
              return
            end

            if !user_to_delete.invitation_accepted_at.nil? or user_to_delete.family.primary_parent.id != @user.id or user_to_delete == @user
              error!({error_code: 403, error_message: "You don't have permission to delete this invitation or it is no longer pending."}, 403)
              return
            end
            result = User.destroy(user_to_delete.id)
          end
        end

        namespace :children do
          # GET users/:id/children
          get do
            puts "In get /users/#{params[:id]}/children"
            if @user != current_user
              error!({error_code: 403, error_message: "You don't have permission to list this user's children."}, 403)
              return
            end
            children = @user.family.children
            present :children, children, with: Leo::Entities::UserEntity
          end

          # POST users/:id/children
          desc "Create a child for this user"
          params do
            requires :first_name, type: String, desc: "First Name"
            requires :last_name,  type: String, desc: "Last Name"
            optional :email,      type: String, desc: "Email", user_unique: true
            requires :dob,        type: String, desc: "Date of Birth"
            requires :sex,        type: String, desc: "Sex", values: ['M', 'F', 'U']
          end
          post do
            puts "In post /users/#{params[:id]}/children"
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
