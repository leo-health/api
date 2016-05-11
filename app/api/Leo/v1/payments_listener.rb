module Leo
  module V1
    class PaymentsListener < Grape::API
      resource :payments_listener do
        post do
          event_type = params["type"]
          related_object = params["data"]["object"]
          case event_type
          when "charge.failed"

            # get user
            # mark delinquent

            # PaymentsMailer.invalid_payment_method
            failure_message = related_object["failure_message"]
            ap params
            ap "The charge failed: #{failure_message}"
          end
        end
      end
    end
  end
end
