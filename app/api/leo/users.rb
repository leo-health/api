module Leo
	class Users < Grape::API
		version 'v1', using: :path, vendor: 'leo-health'
		format :json
		prefix :api

		#rescue_from :all, :backtrace => true
		formatter :json, JSendSuccessFormatter
		error_formatter :json, JSendErrorFormatter

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
			get do
				authenticated_user
				{ users: User.for_user(current_user) }
			end

			desc "Create a user"
			params do
				requires :first_name, type: String, desc: "First Name"
				requires :last_name,  type: String, desc: "Last Name"
				requires :email,      type: String, desc: "Email"
				requires :password,   type: String, desc: "Password"
				# requires :password_confirmation, type: String, desc: "Password again"
				requires :dob,        type: String, desc: "Date of Birth"
				# TODO: allow providing optional family_id
			end
			post do
				if User.where(email: params[:email].downcase).count > 0
					error!({error_code: 400, error_message: "A user with that email already exists"}, 400)
					return
				end


				dob = Chronic.try(:parse, params[:dob])
				if dob.nil?
					error!({error_code: 400, error_message: "Invalid dob format"},400)
					return
				end
				User.create!(
				{
					first_name:   params[:first_name],
					last_name:    params[:last_name],
					email:        params[:email],
					password:     params[:password],
					# password_confirmation: params[:password_confirmation],
					dob:          dob,
					# role:         params[:role]
				})
			end
		end

	end
end
