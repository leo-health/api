module Leo
  module V1
    class DeepLinks < Grape::API
      desc "redirect user to proper page"
      namespace "deep_link" do
        before do
          authenticated
        end

        get do
          byebug
          request.user_agent
        end
      end
    end
  end
end
