module Leo
  module V1
    class Subscriptions < Grape::API
      resource :subscriptions do
        before do
          authenticated
        end

        params do
          requires :credit_card_token, type: String
        end

        post do
          patient_count = current_user.family.patients.count > 5 ? 5 : current_user.family.patients.count
          begin
            stripe_customer = Stripe::Customer.create(
              email: current_user.email,
              plan: StripePlanMap[patient_count],
              source: params[:credit_card_token]
            )
          rescue Stripe::AuthenticationError => e
            error!({error_code: 401, error_message: e.json_body[:error][:code] }, 401)
          rescue Stripe::CardError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{current_user.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError,
                 Stripe::APIConnectionError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
          rescue Stripe::StripeError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{current_user.email}: #{e.json_body[:error][:message]}")
            #suggest sending a email for stripe general errors
          end

          update_success current_user, { stripe_customer_id: stripe_customer.id }, "User"
        end
      end
    end
  end
end
