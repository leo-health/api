module Leo
  module V1
    class Patients < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari

      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

      resource :patients do
        before do
          authenticated
        end

        after_validation do
          @guardian = Session.find_by_authentication_token(params[:authentication_token]).user  
        end

        desc "#get get all patient of individual guardian"
        get do
          authorize! :read, @guardian
          patients = @user.family.patients
          present :patients, patients, with: Leo::Entities::UserEntity
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
          # Check that date makes sense
          dob = Chronic.try(:parse, params[:dob])
          if params[:dob].strip.length > 0 and dob.nil?
            error!({error_code: 422, error_message: "Invalid dob format"},422)
            return
          end

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
          present :user, patient, with: Leo::Entities::UserEntity
        end

        desc "update the patient information, guardian only"
        params do
          optional :first_name, type: String, desc: "First Name"
          optional :last_name,  type: String, desc: "Last Name"
          optional :email,      type: String, desc: "Email"
          optional :dob,        type: String, desc: "Date of Birth"
          optional :sex,        type: String, desc: "Sex", values: ['M', 'F']
          at_least_one_of :first_name, :last_name, :email, :dob, :sex
        end
        
        
        desc "delete the patient information, guardian only"
        params do

        end
      end
    end
  end
end
