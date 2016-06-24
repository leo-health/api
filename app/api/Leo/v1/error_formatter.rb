module Leo
  module V1
    class ErrorFormatter
      def self.call message, backtrace, options, env
        nested_message = message
        nested_message = {debug_message: message} unless message.respond_to?(:keys)
        nested_message[:user_message] ||= "Something went wrong! Please contact us at support@leohealth.com if the problem persists"
        nested_message[:debug_message] = nil if Rails.env.production?
        error_json = { status: 'error', message: nested_message}
        error_json[:backtrace] = backtrace unless Rails.env.production?
        error_json.to_json
      end
    end
  end
end
