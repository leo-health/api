module Leo
  module V1
    class ErrorFormatter
      def self.call message, backtrace, options, env
        nested_message = message
        unless message.respond_to?(:keys) && message[:user_message]
          nested_message = {
            debug_message: message,
            user_message: "Something went wrong! Please contact us at info@leohealth.com if the problem persists",
            error_code: 500
          }
        end
        error_json = { status: 'error', message: nested_message}
        error_json[:backtrace] = backtrace unless Rails.env.production?
        error_json.to_json
      end
    end
  end
end
