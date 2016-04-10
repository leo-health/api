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
          patient.save!
          PostPatientJob.new(patient).start
          create_success patient
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
          patient.save!
          PostPatientJob.new(patient).start
          update_success patient, declared(params, include_missing: false)
        end

        desc "#show: get a patient"
        get ':id' do
          patient = Patient.find(params[:id])
          authorize! :read, patient
          render_success patient
        end

        desc "#index: all patients of a guardian(current_user)"
        get do
          patients = Family.find(current_user.family_id).patients
          authorize! :read, Patient
          present :patients, patients, with: Leo::Entities::PatientEntity
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
