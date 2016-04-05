module Leo
  module V1
    class IosConfiguration < Grape::API
      get :ios_configuration do
        response = ["PUSHER_KEY", "CRITTERCISM_APP_ID", "LOCALYTICS_APP_ID"].inject({}) do |hash, key|
          hash[key] = ENV[key]
          hash
        end

        response.merge(vendor_id: generate_vendor_id)
      end
    end
  end
end
