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
            @guardian = Session.find_by_authentication_token(params[:authentication_token]).user
          end

          desc "#get get all patients of individual guardian"
          get do
            if patients = @guardian.family.patients
              byebug
              authorize! :read, patients
              rescue_from CanCan::AccessDenied do |exception|
                puts "Access denied on #{exception.action} #{exception.subject.inspect}"
              end
              byebug
              present :patients, patients, with: Leo::Entities::UserEntity
            end
          end

          desc "#post create a patient for this guardian"
          params do
            requires :first_name, type: String, desc: "First Name"
            requires :last_name,  type: String, desc: "Last Name"
            optional :email,      type: String, desc: "Email"
            requires :dob,        type: String, desc: "Date of Birth"
            requires :sex,        type: String, desc: "Sex", values: ['M', 'F']
          end

          post do
            authorize! :create, @guardian
            family = @guardian.family
            patient_params = { first_name: params[:first_name],
                               last_name: params[:last_name],
                               email: params[:email],
                               dob: dob,
                               family_id: family.id,
                               sex: params[:sex] }

            if patient = User.create(patient_params)
              patient.add_role :patient
              patient.save!
            end
            present :patient, patient, with: Leo::Entities::UserEntity
          end

          desc "#update: update the patient information, guardian only"
          params do
            requires :id, type: Integer, desc: 'patient id'
            optional :first_name, type: String
            optional :last_name,  type: String
            optional :email,      type: String
            optional :dob,        type: String
            optional :sex,        type: String, values: ['M', 'F']
            at_least_one_of :first_name, :last_name, :email, :dob, :sex
          end
          put ':id' do
            authorize! :update, @guardian
            patient = @guardian.family.patients.find(params[:id])
            if patient && patient.update_attributes(declared(params))
              present :patient, patient, with: Leo::Entities::UserEntity
            end
          end

          desc "#delete: delete individual patient, guardian only"
          delete ':id' do
            authorize! :destroy, @guardian
            @guardian.family.patients.find(params[:id]).try(:destory)
          end
        end
      end
    end
  end
end
