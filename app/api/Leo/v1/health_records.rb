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
              present :immunizations, imunizations, with: Leo::Entities::VaccineEntity
          end

          # get "patients/{patient_id}/vitals/medications"
          desc "get medications"
          get 'medications' do
              meds = Medication.where(patient_id: @patient.id, ended_at: nil).order(:started_at)
              present :medications, meds, with: Leo::Entities::MedicationEntity
          end

          namespace 'notes' do
            # get "patients/{patient_id}/notes"
            desc "get all notes"
            get do
              notes = UserGeneratedHealthRecord.where(patient_id: @patient.id, deleted_at: nil)
              present :notes, notes, with: Leo::Entities::UserGeneratedHealthRecordEntity
            end

            # post "patients/{patient_id}/notes"
            desc "create a new note"
            params do
              requires :note, type: String, allow_blank: false
            end
            post do
              note = UserGeneratedHealthRecord.create(note: params[:note], user: current_user, patient: @patient)
              present :note, note, with: Leo::Entities::UserGeneratedHealthRecordEntity
            end

            route_param :note_id do
              after_validation do
                @note = UserGeneratedHealthRecord.find(params[:note_id])
              end

              # get "patients/{patient_id}/notes/{note_id}"
              desc "get a note"
              get do
                present :note, @note, with: Leo::Entities::UserGeneratedHealthRecordEntity
              end

              desc "update a note"
              params do
                requires :note, type: String
              end
              put do
                @note.note = params[:note]
                @note.save!
                present :note, @note, with: Leo::Entities::UserGeneratedHealthRecordEntity
              end
            end
          end
        end
      end
    end
  end
end
