module Leo
  module V1
    class PatientEnrollments < Grape::API
      resource :patient_enrollments do
        before do
          authenticated
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
          patient = current_user.family.patients.create(declared(params, include_missing: false))
          if patient.valid?
            present :patient_enrollment, patient
          else
            error!({error_code: 422, error_message: patient.errors.full_messages.first }, 422)
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
          patient = Patient.find(params[:id])
          if patient.update_attributes(declared(params, include_missing: false))
            present :patient_enrollment, patient
          else
            error!({error_code: 422, error_message: patient.errors.full_messages.first }, 422)
          end
        end

        desc "remove a patient enrollment record"
        delete ':id' do
          patient = Patient.find(params[:id])
          authorize! :destroy, patient
          patient.destroy and return
        end
      end
    end
  end
end
