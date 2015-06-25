module Leo
  module V1
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
  end
end
