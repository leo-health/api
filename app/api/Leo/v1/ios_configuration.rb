module Leo
  module V1
    class IosConfiguration < Grape::API
      get :ios_configuration do
        ["PUSHER_KEY", "CRITTERCISM_APP_ID"].inject({}) do |hash, key| 
          hash[key] = ENV[key]
          hash
        end
      end
    end
  end
end
