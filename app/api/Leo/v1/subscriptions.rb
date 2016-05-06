module Leo
  module V1
    class Subscriptions < Grape::API
      resource :subscriptions do
        before do
          authenticated
        end

        params do
          requires :credit_card_token, type: String
          requires :plan_id, type: String
        end

        post do
          begin
            stripe_customer = Stripe::Customer.create(
              email: current_user.email,
              plan: params[:plan_id],
              source: params[:credit_card_token]
            )
          rescue Stripe::AuthenticationError => e
            error!({error_code: 401, error_message: e.json_body[:error][:message] }, 401)
          rescue Stripe::CardError => e
            error!({error_code: 422, error_message: e.json_body[:error][:message] }, 422)
            logger.error("#{current_user.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError,
                 Stripe::APIConnectionError => e
            error!({error_code: 422, error_message: e.json_body[:error][:message] }, 422)
          rescue Stripe::StripeError => e
            #suggest sending a email for stripe general errors
          end

          update_success current_user, { stripe_customer_id: stripe_customer.id }
        end
      end
    end
  end
end
