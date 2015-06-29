module Leo
  module V1
    class SuccessFormatter
      def self.call object, env
        { :status => 'ok', :data => object }.to_json
      end
    end
  end
end
