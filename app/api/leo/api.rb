require 'grape'

module Leo
  module JSendSuccessFormatter
      def self.call object, env
        { :status => 'ok', :data => object }.to_json
      end
    end
    module JSendErrorFormatter
      def self.call message, backtrace, options, env
        # This uses convention that a error! with a Hash param is a jsend "fail", otherwise we present an "error"
        if message.is_a?(Hash)
          { :status => 'fail', :data => message }.to_json
        else
          { :status => 'error', :message => message }.to_json
        end
      end
    end
  class API < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    rescue_from :all, :backtrace => true
    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter
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


    mount Sessions
    mount Users
    mount Statuses
  end
end