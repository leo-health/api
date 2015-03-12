require 'grape'
require 'grape-swagger'

class UserUnique < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless User.where(email: params[attr_name].downcase).count == 0
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be unique"
    end
  end
end

class RoleExists < Grape::Validations::Base
  def validate_param!(attr_name, params)
    if Role.where(name: params[attr_name].downcase).count == 0
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be a valid role"
    end
  end
end


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
        { :status => 'fail', :data => message, backtrace: backtrace }.to_json
      else
        { :status => 'error', :message => message, backtrace: backtrace }.to_json
      end
    end
  end

  class API < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    include Grape::Kaminari

    rescue_from :all, :backtrace => true
    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter
    default_error_status 400
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      data = e.map { |k,v| { 
        params: k, 
        messages: (v.class.name == "Grape::Exceptions::Validation" ? v.to_s :  v.map(&:to_s)) } 
      }
      resp = {status: 'error', data: data }
      rack_response resp.to_json, 422
    end

    #before do
    # error!("401 Unauthorized", 401) unless authenticated
    #end
    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end


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

    get do
      {message: "Welcome to the Leo API"}
    end

    mount Appointments
    mount Conversations
    mount Sessions
    mount Statuses
    mount Users

    add_swagger_documentation(
      base_path: "/api",
      hide_documentation_path: true
    )
  end
end