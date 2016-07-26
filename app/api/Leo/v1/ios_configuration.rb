module Leo
  module V1
    class IosConfiguration < Grape::API
      get :ios_configuration do
        keys = ["PUSHER_KEY", "CRITTERCISM_APP_ID", "LOCALYTICS_APP_ID", "STRIPE_PUBLISHABLE_KEY"]
        response = Hash[keys.zip(ENV.values_at(*keys))]
        response.merge(vendor_id: GenericHelper.generate_token(:vendor_id))
      end
    end
  end
end
