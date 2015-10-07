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
            params do
              requires :start_date, type: String, desc: "Start date", allow_blank: false
              requires :end_date, type: String, desc: "End date", allow_blank: false
            end
            get 'height' do
              start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
              end_date = Date.strptime(params[:end_date], "%m/%d/%Y")

              vitals = Vital.where(patient_id: @patient.id, measurement: "VITALS.HEIGHT").where(taken_at: start_date..end_date).order(:taken_at).order(:taken_at).collect() {
                |vital| { :taken_at => vital.taken_at, :value => vital.value, :percentile => GrowthCurvesHelper.height_percentile(@patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_i) }
              }
              present :heights, vitals, with: Leo::Entities::VitalEntity
            end

            # get "patients/{patient_id}/vitals/weight"
            desc "get weight"
            params do
              requires :start_date, type: String, desc: "Start date", allow_blank: false
              requires :end_date, type: String, desc: "End date", allow_blank: false
            end
            get :weight do
              start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
              end_date = Date.strptime(params[:end_date], "%m/%d/%Y")

              vitals = Vital.where(patient_id: @patient.id, measurement: "VITALS.WEIGHT").where(taken_at: start_date..end_date).order(:taken_at).collect() {
                |vital| { :taken_at => vital.taken_at, :value => vital.value, :percentile => GrowthCurvesHelper.weight_percentile(@patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_i) }
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
              imunizations = Vaccine.where(patient_id: @patient.id).order(:administered_at)
              present :imunizations, imunizations, with: Leo::Entities::VaccineEntity
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
