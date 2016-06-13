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
        def user_message_payments_default
          "Sorry, there was an error processing your payment. Please try again later or contact us for help at info@leohealth.com"
        end

        def update_or_create_subscription
          user = current_user
          family = user.family

          error_code = nil
          user_message = user_message_payments_default
          debug_message = ""

          if family.patients.count == 0
            user_message = "You must add a child before you can subscribe to Leo."
            error_code = 422
          elsif !user.complete?
            debug_message = "You can only create a subscription for a complete user"
            error_code = 422
          else
            begin
              unless family.update_or_create_stripe_subscription_if_needed!(params[:credit_card_token])
                debug_message = family.errors.full_messages.to_s
                error_code = 500
              end
            rescue Stripe::CardError => e
              family.expire_membership!
              debug_message = "#{user.email}: #{e.to_s}"
              user_message = "Your card was declined, please try a different one."
              error_code = 422
            rescue Stripe::RateLimitError, Stripe::APIConnectionError, Stripe::AuthenticationError, Stripe::StripeError => e
              debug_message = "Stripe Error: #{e.to_s}"
              error_code = 500
              @logger.error(debug_message)
            end
          end

          if error_code
            error!({
              error_code: error_code,
              user_message: user_message,
              debug_message: debug_message
            }, error_code)
          end
          true
        end
      end
    end
  end
end
