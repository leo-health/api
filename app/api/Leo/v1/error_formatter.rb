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
        { status: 'error', message: nested_message, backtrace: backtrace }.to_json
      end
    end
  end
end
