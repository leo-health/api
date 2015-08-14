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
          error_response(message: e.message, status: 406)
        end

        rescue_from :all do |e|
          rescue_from :all, :backtrace => true
          error_response(message: 'Internal server error', status: 500)
        end
      end
    end
  end
end
