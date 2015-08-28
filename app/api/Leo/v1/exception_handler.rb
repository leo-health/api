module Leo
  module V1
    module ExceptionsHandler
      extend ActiveSupport::Concern
      included do
        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: {error_code: 422, error_message: e.message}, status: 404)
        end

        rescue_from CanCan::AccessDenied do |e|
          error_response(message: {error_code: 422, error_message: e.message}, status: 403)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          data = e.map { |k,v| {
            params: k,
            messages: (v.class.name == "Grape::Exceptions::Validation" ? v.to_s :  v.map(&:to_s)) }
          }
          resp = {status: 'error', message: {error_code: 422, error_message: data}}
          rack_response resp.to_json, 422
        end

        rescue_from :all, :backtrace => true
      end
    end
  end
end
