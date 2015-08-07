module Leo
  module V1
    class Patients < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

      namespace 'users/:user_id' do
        resource :patients do
          before do
            authenticated
          end

          after_validation do
            @guardian = User.find(params[:user_id])
          end

          desc "#get retrieve all patients of a guardian"
          get do
            if patients = @guardian.family.patients
              present :patients, patients, with: Leo::Entities::PatientEntity
            else
              error!('unprocessable_entity', 422)
            end
          end

          desc "#post create a patient for a guardian"
          params do
            requires :first_name, type: String
            requires :last_name, type: String
            requires :birth_date, type: String
            requires :sex, type: String, values: ['M', 'F']
            optional :title, type: String
            optional :suffix, type: String
            optional :middle_initial, type: String
            optional :email, type: String
          end

          post do
            if family = @guardian.family
              patient = family.patients.create(declared(params, including_missing: false))
            else
              error!('unprocessable_entity', 422)
            end

            present :patient, patient, with: Leo::Entities::PatientEntity
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
              error!('unprocessable_entity', 422)
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
end
