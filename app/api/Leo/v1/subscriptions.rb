module Leo
  module V1
    class Subscriptions < Grape::API
      resource :subscriptions do
        params do
          requires :credit_card_token, type: String
        end

        post do
          enrollment = Enrollment.find_by_authentication_token(params[:authentication_token])
          error!({error_code: 401, error_message: "Invalid Token" }, 401) unless enrollment

          patient_count = enrollment.patient_enrollments.count
          patient_count = 5 if patient_count > 5
          begin
            stripe_customer = Stripe::Customer.create(
              email: enrollment.email,
              plan: StripePlanMap[patient_count],
              source: params[:credit_card_token]
            )
          rescue Stripe::AuthenticationError => e
            error!({error_code: 401, error_message: e.json_body[:error][:code] }, 401)
          rescue Stripe::CardError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{current_user.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
          rescue Stripe::StripeError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{current_user.email}: #{e.json_body[:error][:message]}")
            #suggest sending a email for stripe general errors
          end
          update_success enrollment, stripe_customer_id: stripe_customer.id
        end
      end
    end
  end
end
