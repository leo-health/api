module Leo
  module V1
    class Subscriptions < Grape::API
      resource :subscriptions do
        before do
          authenticated
        end

        namespace :validate_coupon do
          params do
            requires :coupon_id, type: String
          end

          get do
            begin
              coupon = Stripe::Coupon.retrieve(params[:coupon_id])
            rescue Stripe::InvalidRequestError => e
              error!({ error_code: 422, user_message: "#{params[:coupon_id]} is not a valid promo code"}, 422)
            end

            text = case coupon.duration
            when 'forever'
              'Your membership is free forever'
            when 'once'
              'Your first month of membership is on us!'
            when 'repeating'
              "Your first #{coupon.duration_in_months} months are on us!"
            end

            present :coupon, coupon
            present :text, text
          end
        end

        params do
          requires :credit_card_token, type: String
          optional :coupon_id, type: String
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
          "Sorry, there was an error processing your payment. Please try again later or contact us for help at support@leohealth.com"
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
          else
            begin
              unless family.update_or_create_stripe_subscription_if_needed!(params[:credit_card_token], params[:coupon_id])
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

          family.stripe_customer
        end
      end
    end
  end
end
