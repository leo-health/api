module Leo
  module V1
    class Patients < Grape::API
      include Grape::Kaminari
      resource :patients do
        before do
          authenticated
        end

        desc "#post create a patient for current guardian"
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :birth_date, type: String, allow_blank: false
          requires :sex, type: String, values: ['M', 'F']
          optional :title, type: String
          optional :suffix, type: String
          optional :middle_initial, type: String
          optional :email, type: String
        end

        post do
          patient = current_user.family.patients.new(declared(params, including_missing: false))
          authorize! :create, patient
          if patient.save
            present :patient, patient, with: Leo::Entities::PatientEntity
          else
            error!({error_code: 422, error_message: patient.errors.full_messages}, 422)
          end
        end

        desc "#update: the patient information, guardian only"
        params do
          optional :title, type: String
          optional :suffix, type: String
          optional :middle_initial, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :email, type: String
          optional :birth_date, type: String
          optional :sex, type: String, values: ['M', 'F']
          at_least_one_of :first_name, :last_name, :email, :birth_date, :sex, :title, :suffix, :middle_initial
        end

        put ':id' do
          patient = Patient.find(params[:id])
          authorize! :update, patient
          if patient && patient.update_attributes(declared(params, include_missing: false))
            present :patient, patient, with: Leo::Entities::PatientEntity
          else
            error!({error_code: 422, error_message: patient.errors.full_messages}, 422)
          end
        end

        desc "#delete: delete individual patient, guardian only"
        delete ':id' do
          patient = Patient.find(params[:id])
          authorize! :destroy, patient
          patient.try(:destroy)
        end
      end
    end
  end
end
