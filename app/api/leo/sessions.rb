module Leo
	class Sessions < Grape::API
		version 'v1', using: :path, vendor: 'leo-health'
		format :json
		prefix :api

		rescue_from :all, :backtrace => true
		formatter :json, JSendSuccessFormatter
		error_formatter :json, JSendErrorFormatter
		default_error_status 400

		resource :sessions do

			desc "Authenticate user and return user object / access token"
			params do
				requires :email, type: String, desc: "User email"
				requires :password, type: String, desc: "User Password"
			end

			post do
				email = params[:email]
				password = params[:password]

				# A blank value was submitted for one of the paramaters
				if email.nil? or password.nil?
					error!({error_code: 404, error_message: "Invalid Email or Password."},401)
					return
				end

				# The user doesn't exist, or the password for the user is not valid
				user = User.where(email: email.downcase).first
				if user.nil? or !user.valid_password?(password)
					error!({error_code: 404, error_message: "Invalid Email or Password."},401)
					return
				end
				
				# Prevent children from logging in (Issue #59)
				if user.has_role? :child
					error!({error_code: 404, error_message: "This user is not allowed to log in."},401)
					return
				end					

				# Everything checks out. Log them in
				user.ensure_authentication_token
				user.save
				present :token, user.authentication_token
				present	:user, user, with: Leo::Entities::UserEntity
			end

			desc "Destroy the access token"
			params do
				requires :access_token, type: String, desc: "User Access Token"
			end
			delete ':access_token' do
				access_token = params[:access_token]
				user = User.where(authentication_token: access_token).first

				# The user doesn't exist
				if user.nil?
					error!({error_code: 404, error_message: "Invalid access token."},401)
					return
				else # Everything checks out. Reset their authentication token
					user.reset_authentication_token
				 #{status: 'ok'}
				end
			end

			resource :password do

				desc "Reset password"
				params do 
					requires :email, type: String, desc: "User email for account to reset password"
				end

				post do 
					email = params[:email]

					# A blank value was submitted for one of the paramaters
					if email.nil?
						error!({error_code: 404, error_message: "Invalid email."}, 401)
						return
					end

					user = User.where(email: email.downcase).first

					# The user doesn't exist
					if user.nil?
						return
					else # Everything checks out. Send the user a 
						user.send_reset_password_instructions
						# user.save TODO: Think about whether resetting the auth token makes sense when requesting password reset
					end
				end

				desc "Change password"
				params do
					requires :email, type: String, desc: "User email for account to change password"
					requires :old_password, type: String, desc: "The old password to confirm this user has the right to change passwords"
					requires :new_password, type: String, desc: "The new password to replace the old one with"
					requires :new_password_confirmation, type: String, desc: "The new password, again to ensure no mistakes"
				end

				put do
					email = params[:email]
					old_password = params[:old_password]
					new_password = params[:new_password]
					new_password_confirmation = params[:new_password_confirmation]

					# A blank value was submitted for one of the paramaters
					if email.nil? or old_password.nil? or new_password.nil? or new_password_confirmation.nil?
						error!({error_code: 404, error_message: "Invalid email or password."})
						return
					end

					user = User.where(email: email.downcase).first
					# The user doesn't exist, or the password for the user is not valid
					if user.nil? or !user.valid_password?(password)
						error!({error_code: 404, error_message: "Invalid Email or Password."},401)
						return
					end

					# The new_password and new_password confirmation don't match
					if new_password != new_password_confirmation
						error!({error_code: 404, error_message: "New Password and New Password Confirmation don't match."})
						return
					else
						user.reset_password!(new_password, new_password_confirmation)
						{ status: 'ok' }
					end
				end
			end
		end
	end
end