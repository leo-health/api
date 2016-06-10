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
            success = family.update_or_create_stripe_subscription_if_needed! params[:credit_card_token]
            unless success
              if family.primary_guardian
                debug_message = family.errors.full_messages.to_s
              else
                debug_message = "You can only create a subscription with a complete user"
              end
              error!({
                error_code: 422,
                user_message: "Sorry, we did something wrong and couldn't process your payment. Please try again later or contact us for help at info@leohealth.com",
                debug_message: debug_message
              }, 422)
            end
            success
          rescue Stripe::AuthenticationError => e
            error!(
              {
                error_code: 500,
                user_message: "Sorry, we did something wrong and couldn't process your payment. Please try again later or contact us for help at info@leohealth.com",
                debug_message: "Stripe::AuthenticationError #{e.to_s}"
              }, 500)
          rescue Stripe::CardError => e
            family.expire_membership!
            debug_message = "#{user.email}: #{e.to_s}"
            error!(
              {
                error_code: 422,
                user_message: "Your card was declined, please try a different one.",
                debug_message: debug_message
              }, 422)
            logger.error(debug_message)
          rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
            error!(
              {
                error_code: 500,
                user_message: "Sorry, we did something wrong and couldn't process your payment. Please try again later or contact us for help at info@leohealth.com",
                debug_message: "Stripe::RateLimitError APIConnectionError #{e.to_s}"
              }, 500)
          rescue Stripe::StripeError => e
            error!(
              {
                error_code: 500,
                user_message: "Sorry, we did something wrong and couldn't process your payment. Please try again later or contact us for help at info@leohealth.com",
                debug_message: "Stripe::StripeError #{debug_message}"
              }, 500)
            logger.error(debug_message)
          end
        end
      end
    end
  end
end
