require 'grape'

module Leo
  class API < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    rescue_from :all, :backtrace => true
    # error_formatter :json, API::ErrorFormatter

    #before do
    # error!("401 Unauthorized", 401) unless authenticated
    #end


    helpers do
      #def current_user
      #  @current_user ||= User.authorize!(env)
      #end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
      def warden
        env['warden']
      end
      def authenticated
        return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end
      def current_user
        warden.user || @user
      end
      # returns 403 if there's no current user
      def authenticated_user
        authenticated
        error!('Forbidden', 403) unless current_user
      end
    end

    resource :users do 
      desc "Return a user"
      params do 
        requires :id, type: Integer, desc: "User id"
      end
      route_param :id do 
        get do
          User.find(params[:id])
        end
      end

      desc "Create a user"
      params do
        requires :first_name, type: String, desc: "First Name"
        requires :last_name,  type: String, desc: "Last Name"
        requires :email,      type: String, desc: "Email"
        requires :password,   type: String, desc: "Password"
        # requires :password_confirmation, type: String, desc: "Password again"
        requires :dob,        type: String, desc: "Date of Birth"
      end
      post do
        if User.where(email: params[:email]).count > 0
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


    resource :statuses do
      desc "Return a public timeline."
      get :public_timeline do
        Status.limit(20)
      end

      desc "Return a personal timeline."
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end

      desc "Return a status."
      params do
        requires :id, type: Integer, desc: "Status id."
      end
      route_param :id do
        get do
          Status.find(params[:id])
        end
      end

      desc "Create a status."
      params do
        requires :status, type: String, desc: "Your status."
      end
      post do
        authenticate!
        Status.create!({
          user: current_user,
          text: params[:status]
        })
      end

      desc "Update a status."
      params do
        requires :id, type: String, desc: "Status ID."
        requires :status, type: String, desc: "Your status."
      end
      put ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).update({
          user: current_user,
          text: params[:status]
        })
      end

      desc "Delete a status."
      params do
        requires :id, type: String, desc: "Status ID."
      end
      delete ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).destroy
      end
    end
    mount Sessions
  end
end