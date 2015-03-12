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
			
			desc "Return a user"
			params do 
				requires :id, type: Integer, desc: "User id"
			end
			route_param :id do 
				get do
					authenticated_user
					User.find(params[:id])
				end
			end

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
				requires :email,      type: String, desc: "Email"
				requires :password,   type: String, desc: "Password"
				requires :role,				type: String, desc: "Role for the user. Get list from /roles"
				requires :dob,        type: String, desc: "Date of Birth"

			end
			post do
				if User.where(email: params[:email].downcase).count > 0
					error!({error_code: 422, error_message: "A user with that email already exists"}, 422)
					return
				end


				dob = Chronic.try(:parse, params[:dob])
				if dob.nil?
					error!({error_code: 422, error_message: "Invalid dob format"},422)
					return
				end

				role = Role.where(name: params[:role])
				if params[:role].nil? or role.nil?
					error!({error_code: 422, error_message: "Invalid role."}, 422)
					return
				end

				family = Family.create! 

				user = User.create!(
				{
					first_name:   params[:first_name],
					last_name:    params[:last_name],
					email:        params[:email],
					password:     params[:password],
					dob:          dob,
					family_id: 		family.id
				})
				user.roles << role
				present :user, user, with: Leo::Entities::UserEntity
			end
		end

	end
end
