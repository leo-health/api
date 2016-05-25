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
          user = current_user
          family = user.family

          patient_count = family.patients.count
          patient_count = 5 if patient_count > 5
          begin
            stripe_customer = Stripe::Customer.create(
              email: user.email,
              plan: StripePlanMap[patient_count],
              source: params[:credit_card_token]
            )
          rescue Stripe::AuthenticationError => e
            error!({error_code: 401, error_message: e.json_body[:error][:code] }, 401)
          rescue Stripe::CardError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{user.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
          rescue Stripe::StripeError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{user.email}: #{e.json_body[:error][:message]}")
            #suggest sending a email for stripe general errors
          end
          family.stripe_customer_id = stripe_customer.id
          family.renew_membership
          family.save!
        end
      end
    end
  end
end
