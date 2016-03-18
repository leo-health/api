module Leo
  module V1
    class IosConfiguration < Grape::API
      get :ios_configuration do
        config = {}
        ["PUSHER_KEY", "CRITTERCISM_APP_ID"].each { |key| config[key] = ENV[key] }
        config
      end
    end
  end
end
