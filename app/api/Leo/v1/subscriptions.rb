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

          family = Family.new_from_enrollment enrollment
          error!({error_code: 422, error_message: family.errors.full_messages }, 422) unless family.save

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
            logger.error("#{enrollment.email}: #{e.json_body[:error][:message]}")
          rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
          rescue Stripe::StripeError => e
            error!({error_code: 422, error_message: e.json_body[:error][:code] }, 422)
            logger.error("#{enrollment.email}: #{e.json_body[:error][:message]}")
            #suggest sending a email for stripe general errors
          end
          enrollment.stripe_customer_id = stripe_customer.id
          family.stripe_customer_id = stripe_customer.id
          error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422) unless enrollment.save
          create_success family
        end
      end
    end
  end
end
