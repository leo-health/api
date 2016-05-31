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
          update_or_create_subscription
        end

        put do
          update_or_create_subscription
        end
      end

      helpers do
        def update_or_create_subscription
          user = current_user
          family = user.family
          begin
            family.update_or_create_stripe_subscription_if_needed! params[:credit_card_token]
          rescue Stripe::AuthenticationError => e
            error!({error_code: 500, error_message: "Stripe::AuthenticationError #{e.json_body[:error][:code]}" }, 500)
          rescue Stripe::CardError => e
            family.expire_membership!
            error!({error_code: 422, error_message: "Your card was declined, please try a different one." }, 422)
            logger.error("#{user.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
            error!({error_code: 500, error_message: "Stripe::RateLimitError APIConnectionError #{e.json_body[:error][:code]}" }, 500)
          rescue Stripe::StripeError => e
            error!({error_code: 500, error_message: "Stripe::StripeError #{e.to_s}" }, 500)
            logger.error("#{user.email}: #{e.to_s}")
            #suggest sending a email for stripe general errors
          end
        end
      end
    end
  end
end
