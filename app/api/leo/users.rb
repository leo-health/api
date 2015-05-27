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

    #rescue_from :all, :backtrace => true
    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter

    resource :roles do
      desc "Return all roles"
      get "/" do 
        present :roles, Role.all, with: Leo::Entities::RoleEntity
      end
    end

    resource :users do 
      
      desc "Get available users"
      paginate per_page: 20
      get do
        authenticated_user
        present :users, paginate(User.for_user(current_user))
      end

      desc "Create a user"
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
        if dob.nil?
          error!({error_code: 422, error_message: "Invalid dob format"},422)
          return
        end

        role = Role.where(name: params[:role])
        family = Family.create! 

        user = User.create!(
        {
          first_name:   params[:first_name],
          last_name:    params[:last_name],
          email:        params[:email],
          password:     params[:password],
          dob:          dob,
          family_id:    family.id,
          sex:          params[:sex]
        })
        user.roles << role
        family.conversation.participants << user
        present :user, user, with: Leo::Entities::UserEntity
      end

      desc "Calls specific to a user"
      route_param :id do 
        before do
          puts "users/:id - before"
          authenticated_user
        end
        after_validation do
          puts "users/:id - after_validation"
          @user = User.find(params[:id])
        end
        desc "Return a user"
        get do
          present :user, @user, with: Leo::Entities::UserEntity
        end
        
        namespace :invitations do

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
            requires :email,      type: String, desc: "Email", user_unique: true
            requires :family_id,  type: Integer, desc: "Family Id for the new user"
            requires :dob,        type: String, desc: "Date of Birth"
            requires :sex,        type: String, desc: "Sex", values: ['M', 'F', 'U']
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

            # Check that family exists and this user has access to that family
            family_id = params[:family_id]
            family = Family.find_by_id(family_id)
            if family.nil? or family_id != @user.family_id
              error!({error_code: 422, error_message: "Invalid family"},422)
              return
            end

            invited_user = User.invite!(
              email:        params[:email],
              first_name:   params[:first_name],
              last_name:    params[:last_name],
              dob:          dob,
              family_id:    family.id,
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
            role = Role.where(name: :child)
            
            child = User.create!(
            {
              first_name:   params[:first_name],
              last_name:    params[:last_name],
              email:        params[:email],
              dob:          dob,
              family_id:    family.id,
              sex:          params[:sex]
            })

            
            child.add_role :child
            present :child, child, with: Leo::Entities::UserEntity
          end

        end
      end


    end
  end
end
