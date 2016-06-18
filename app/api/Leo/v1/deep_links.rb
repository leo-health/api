module Leo
  module V1
    class DeepLinks < Grape::API
      desc "redirect user to proper page"
      namespace "deep_link" do
        params do
          requires :type, type: String, allow_blank: false
          requires :type_id, type: Integer, allow_blank: false
        end

        get do
          user_agent = UserAgent.parse(request.user_agent)
          if user_agent.platform == "iPhone"
            redirect "#{ENV['DEEPLINK_SCHEME']}://feed/#{params[:type]}/#{params[:type_id]}", permanent: true
          else
            redirect "#{ENV['PROVIDER_APP_HOST']}/invalid-device", permanent: true
          end
        end
      end
    end
  end
end
