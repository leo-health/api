module Leo
  module V1
    class PatientInsurances < Grape::API
      namespace 'patients' do
        before do
          authenticated
        end

        route_param :patient_id do
          after_validation do
            @patient = Patient.find(params[:patient_id])
            authorize! :read, @patient
          end

          # get "patients/{patient_id}/insurances"
          desc "get insurances"
          get 'insurances' do
            insurances = Insurance.where(patient: @patient)
            present :insurances, insurances, with: Leo::Entities::PatientInsuranceEntity
          end
        end
      end
    end
  end
end
