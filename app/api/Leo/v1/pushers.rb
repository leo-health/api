module Leo
  module V1
    class Pushers < Grape::API
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
          response = Pusher[params[:channel_name]].authenticate(params[:socket_id], { :user_id => current_user.id })
          present response
        end
      end

      desc "receive pusher webhooks"
      namespace "pusher/webhook" do
        post do
          webhook = Pusher.webhook.new(request)
          byebug
        end
        # if webhook.valid?
        #
        #   webhook.events.each do |event|
        #     case event["member_added"]
        #       when 'channel_occupied'
        #         puts "Channel occupied: #{event["channel"]}"
        #       when 'channel_vacated'
        #         puts "Channel vacated: #{event["channel"]}"
        #     end
        #   end
        #   render text: 'ok'
        # else
        #   render text: 'invalid', status: 401
        # end
      end
    end
  end
end
