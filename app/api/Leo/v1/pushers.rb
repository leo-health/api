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
    end
  end
end
