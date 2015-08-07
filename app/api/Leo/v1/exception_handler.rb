module Leo
  module V1
    module ExceptionsHandler
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from CanCan::AccessDenied do |e|
          error_response(message: e.message, status: 403)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          data = e.map { |k,v| {
              params: k,
              messages: (v.class.name == "Grape::Exceptions::Validation" ? v.to_s :  v.map(&:to_s)) }
          }
          resp = {status: 'error', data: data }
          rack_response resp.to_json, 422
        end

        rescue_from :all do |e|
          Rails.logger.error "\n#{e.class.name} (#{e.message}):"
          e.backtrace.each { |line| Rails.logger.error line }
          error_response(message: 'Internal server error', status: 500)
        end
      end
    end
  end
end
