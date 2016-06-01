require 'net/http'
module Leo
  module V1
    class ValidatedJson < Grape::API
      params do
        requires :source, type: String, desc: "Source url that may or may not return valid json", allow_blank: false
      end

      get :validated_json do
        url = URI.parse params[:source]
        raw = Net::HTTP.get_response url
        if raw.code == '200'
          begin
            JSON.parse(raw.body)
          rescue JSON::ParserError
            error!({error_code: 422, error_message: "Error parsing JSON from the given source" }, 422)
          end
        end
        redirect url.to_s
      end
    end
  end
end
