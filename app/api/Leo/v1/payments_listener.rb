module Leo
  module V1
    class PaymentsListener < Grape::API
      resource :payments_listener do
        post do
          event_type = params["type"]
          related_object = params["data"]["object"]
          case event_type
          when "invoice.payment_failed"
            customer_id = related_object["customer"]
            if family = Family.find_by_stripe_customer_id(customer_id)
              family.expire_membership! unless related_object["next_payment_attempt"]
              PaymentsMailer.invalid_payment_method family
            end
          end
        end
      end
    end
  end
end
