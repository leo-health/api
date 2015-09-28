module Leo
  module V1
    class PatientEnrollments < Grape::API
      resource :patient_enrollments do
        desc "create a patient enrollment record"
        params do
          requires :guardian_enrollment_id, type: Integer
          requires :first_name, type: String
          requires :last_name, type: String
          requires :sex, type: String, values: ['M', 'F']
          requires :birth_date, type: Date
          optional :title, type: String
          optional :middle_inital, type: String
          optional :suffix, type: String
        end
        post do
          patient_enrollment = Enrollment.create(declared(params, include_missing: false))
          if patient_enrollment.valid?
            present :patient_enrollment, patient_enrollment
          else
            error!({error_code: 422, error_message: enrollment.errors.full_messages }, 422)
          end
        end
      end
    end
  end
end
