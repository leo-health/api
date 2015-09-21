module Leo
  module V1
    class Enrollments < Grape::API
      resource :enrollments do
        desc "create an enrollment"
        params do
          requires :email, type: String, validate_email: true
          requires :password, type: String
        end
        post do
          enrollment = Enrollment.create(declared(params).merge({role_id: 4}))
          if enrollment.valid?
            present :enrollment, enrollment
          else
            error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422)
          end
        end

        desc "update an enrollment"
        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :birth_date, type: Date
          optional :sex, type: String, values: ['M', 'F']
          optional :stripe_customer_id, type: String
        end
        put ":id" do
          enrollment = Enrollment.find(params[:id])
          if enrollment.update_attributes(declared(params, include_missing: false))
            present :enrollment, enrollment
          else
            error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422)
          end
        end
      end
    end
  end
end
