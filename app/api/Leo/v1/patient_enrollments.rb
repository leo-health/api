module Leo
  module V1
    class PatientEnrollments < Grape::API
      resource :patient_enrollments do
        before do
          @enrollment = Enrollment.find_by_authentication_token(params[:authentication_token])
          error!('401 Unauthorized', 401) unless @enrollment
        end

        desc "create a patient enrollment record"
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :sex, type: String, values: ['M', 'F']
          requires :birth_date, type: Date
          optional :email, type: String
          optional :title, type: String
        end
        post do
          patient_enrollment = @enrollment.patient_enrollments.create(declared(params, include_missing: false))
          if patient_enrollment.valid?
            present :patient_enrollment, patient_enrollment
          else
            error!({error_code: 422, error_message: patient_enrollment.errors.full_messages }, 422)
          end
        end

        desc "update a patient enrollment record"
        params do
          optional :email, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :sex, type: String, values: ['M', 'F']
          optional :birth_date, type: Date
          optional :title, type: String
        end
        put ':id' do
          patient_enrollment = PatientEnrollment.find(params[:id])
          if patient_enrollment.update_attributes(declared(params, include_missing: false))
            present :patient_enrollment, patient_enrollment
          else
            error!({error_code: 422, error_message: patient_enrollment.errors.full_messages }, 422)
          end
        end

        desc "remove a patient enrollment record"
        delete ':id' do
          patient_enrollment = PatientEnrollment.find(params[:id])
          patient_enrollment.destroy and return
        end
      end
    end
  end
end
