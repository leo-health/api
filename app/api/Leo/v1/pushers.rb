module Leo
  module V1
    class Pushers < Grape::API
      formatter :json, ->(object, env) { object.to_json }

      desc "control access to pusher channel"
      namespace "pusher/auth" do
        before do
          authenticated
        end

        params do
          requires :channel_name, type: String, allow_blank: false
          requires :socket_id, type: String, allow_blank: false
        end

        post do
          status 200
          Pusher[params[:channel_name]].authenticate(params[:socket_id], { user_id: current_user.id })
        end
      end

      desc "receive pusher webhooks"
      namespace "pusher/webhooks" do
        post do
          webhook = Pusher.webhook(request)
          if webhook.valid?
            webhook.events.each do |event|
              case event["name"]
                when 'member_added'
                  $redis.set("#{event["user_id"]}online?", "yes") if event["channel"] == "presence-provider_app"
                when 'member_removed'
                  $redis.set("#{event["user_id"]}online?", "no") if event["channel"] == "presence-provider_app"
              end
            end
          end
        end
      end
    end
  end
end
