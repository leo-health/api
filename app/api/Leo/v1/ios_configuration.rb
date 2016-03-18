module Leo
  module V1
    class IosConfiguration < Grape::API
      get :ios_configuration do
        keys = ["PUSHER_KEY", "CRITTERCISM_APP_ID"]
        ENV.select do |k, v| keys.include? k end
      end
    end
  end
end
