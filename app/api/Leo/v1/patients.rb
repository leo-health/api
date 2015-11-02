module Leo
  module V1
    class Patients < Grape::API
      include Grape::Kaminari

      desc "return patients with matched names"
      namespace :search_patient do
        before do
          authenticated
        end

        params do
          requires :query, type: String, allow_blank: false
        end

        get do
          error!({error_code: 422, error_message: 'query must have at least two characters'}, 422) if params[:query].length < 2
          results = Patient.search(params[:query])
          present results, with: Leo::Entities::PatientEntity
        end
      end

      resource :patients do
        before do
          authenticated
        end

        desc "#post create a patient for current guardian"
        params do
          optional :title, type: String
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :birth_date, type: String, allow_blank: false
          requires :sex, type: String, values: ['M', 'F']
          optional :suffix, type: String
          optional :middle_initial, type: String
          optional :email, type: String
        end

        post do
          patient = current_user.family.patients.new(declared(params, including_missing: false))
          authorize! :create, patient
          render_success patient
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

        desc "#show: get a patient"
        params do
         optional :avatar_size, type: String, values: ["primary_3x", "primary_2x", "primary_1x"]
        end

        get ':id' do
          patient = Patient.find(params[:id])
          authorize! :read, patient
          present :patient, patient, with: Leo::Entities::PatientEntity, avatar_size: params[:avatar_size].try(:to_sym)
        end

        desc "#index: all patients of a guardian(current_user)"
        params do
          optional :avatar_size, type: String, values: ["primary_3x", "primary_2x", "primary_1x"]
        end

        get do
          patients = Family.find(current_user.family_id).patients
          authorize! :read, Patient
          present :patients, patients, with: Leo::Entities::PatientEntity, avatar_size: params[:avatar_size].to_sym
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
