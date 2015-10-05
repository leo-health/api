module Leo
  module V1
    class HealthRecords < Grape::API
      namespace 'patients' do
        before do
          authenticated
        end

        route_param :patient_id do
          after_validation do
            @patient = Patient.find(params[:patient_id])
            authorize! :read, @patient
          end

          namespace 'vitals' do
            # get "patients/{patient_id}/vitals/height"
            desc "get height"
            get 'height' do
              vitals = Vital.where(patient_id: @patient.id, measurement: "HEIGHT").order(:taken_at).collect() {
                |vital| { :taken_at => vital.taken_at, :value => vital.value, :percentile => 0 }
              }
              present :heights, vitals, with: Leo::Entities::VitalEntity
            end

            # get "patients/{patient_id}/vitals/weight"
            desc "get weight"
            get :weight do
              vitals = Vital.where(patient_id: @patient.id, measurement: "WEIGHT").order(:taken_at).collect() {
                |vital| { :taken_at => vital.taken_at, :value => vital.value, :percentile => 0 }
              }
              present :weights, vitals, with: Leo::Entities::VitalEntity
            end
          end

          # get "patients/{patient_id}/allergies"
          desc "get allergies"
          get 'allergies' do
              allergies = Allergy.where(patient_id: @patient.id).order(:onset_at)
              present :allergies, allergies, with: Leo::Entities::AllergyEntity
          end

          # get "patients/{patient_id}/immunizations"
          desc "get immunizations"
          get 'immunizations' do
              imunizations = Immunization.where(patient_id: @patient.id, ended_at: nil).order(:started_at)
              present :imunizations, imunizations, with: Leo::Entities::ImmunizationEntity
          end

          # get "patients/{patient_id}/vitals/medications"
          desc "get medications"
          get 'medications' do
              meds = Medication.where(patient_id: @patient.id, ended_at: nil).order(:started_at)
              present :medications, meds, with: Leo::Entities::MedicationEntity
          end

          namespace 'notes' do
          end
        end
      end
    end
  end
end
