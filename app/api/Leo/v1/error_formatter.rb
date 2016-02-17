module Leo
  module V1
    class ErrorFormatter
      def self.call message, backtrace, options, env
        { status: 'error', message: message, backtrace: backtrace }.to_json
      end
    end
  end
end
