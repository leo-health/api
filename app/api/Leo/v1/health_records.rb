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

          get 'phr' do
            #vitals: height weight, bmi
            height_vitals = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_HEIGHT).order(:taken_at).collect() {
              |vital| {
                measurement: vital.measurement,
                taken_at: vital.taken_at,
                value: GrowthCurvesHelper.cm_to_inches(vital.value.to_f).round(2),
                unit: "inches",
                percentile: GrowthCurvesHelper.height_percentile(
                  @patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_f)
              }
            }

            weight_vitals = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_WEIGHT).order(:taken_at).collect() {
              |vital| {
                measurement: vital.measurement,
                taken_at: vital.taken_at,
                value: GrowthCurvesHelper.g_to_lbs(vital.value.to_f).round(2),
                unit: "lbs",
                percentile: GrowthCurvesHelper.weight_percentile(
                  @patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_f/1000)
              }
            }

            bmi_vitals = []
            start_date = DateTime.new(1900, 1, 1)
            Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_WEIGHT).order(:taken_at).each do | weight_vital |
              height_vital = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_HEIGHT, taken_at: start_date..weight_vital.taken_at.end_of_day).order(:taken_at).last
              if height_vital
                weight_kg = weight_vital.value.to_f/1000
                height_m = height_vital.value.to_f/100
                bmi = weight_kg/(height_m * height_m)
                bmi_vitals << {
                  taken_at: weight_vital.taken_at,
                  value: bmi.round(1),
                  unit: "",
                  percentile: GrowthCurvesHelper.bmi_percentile(@patient.sex, @patient.birth_date.to_datetime, weight_vital.taken_at.to_datetime, (bmi.to_f).round(1))
                }
              end
            end

            allergies = Allergy.where(patient: @patient).order(:onset_at)
            immunizations = Vaccine.where(patient: @patient).order(:administered_at)
            meds = Medication.where(patient: @patient, ended_at: nil).order(:started_at)
            phr = {
              :heights => height_vitals,
              :weights => weight_vitals,
              :bmis => bmi_vitals,
              :allergies => allergies,
              :immunizations => immunizations,
              :medications => meds
            }

            present phr, with: Leo::Entities::PHREntity
          end

          namespace 'vitals' do
            desc "get height"
            params do
              requires :start_date, type: String, desc: "Start date", allow_blank: false
              requires :end_date, type: String, desc: "End date", allow_blank: false
            end

            get 'height' do
              start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
              end_date = Date.strptime(params[:end_date], "%m/%d/%Y")
              vitals = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_HEIGHT).where(taken_at: start_date..end_date.end_of_day).order(:taken_at).collect() {
                |vital| {
                  measurement: vital.measurement,
                  taken_at: vital.taken_at,
                  value: GrowthCurvesHelper.cm_to_inches(vital.value.to_f).round(2),
                  unit: "inches",
                  percentile: GrowthCurvesHelper.height_percentile(
                    @patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_f)
                }
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
              vitals = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_WEIGHT).where(taken_at: start_date..end_date.end_of_day).order(:taken_at).collect() {
                |vital| {
                  measurement: vital.measurement,
                  taken_at: vital.taken_at,
                  value: GrowthCurvesHelper.g_to_lbs(vital.value.to_f).round(2),
                  unit: "lbs",
                  percentile: GrowthCurvesHelper.weight_percentile(
                    @patient.sex, @patient.birth_date.to_datetime, vital.taken_at.to_datetime, vital.value.to_f/1000)
                }
              }

              present :weights, vitals, with: Leo::Entities::VitalEntity
            end

            # get "patients/{patient_id}/vitals/bmi"
            desc "get bmi"
            params do
              requires :start_date, type: String, desc: "Start date", allow_blank: false
              requires :end_date, type: String, desc: "End date", allow_blank: false
            end

            get :bmis do
              start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
              end_date = Date.strptime(params[:end_date], "%m/%d/%Y")
              vitals = []
              Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_WEIGHT).where(taken_at: start_date..end_date.end_of_day).order(:taken_at).each do | weight_vital |
                height_vital = Vital.where(patient: @patient, measurement: Vital::MEASUREMENT_HEIGHT, taken_at: start_date..weight_vital.taken_at.end_of_day).order(:taken_at).last
                if height_vital
                  weight_kg = weight_vital.value.to_f/1000
                  height_m = height_vital.value.to_f/100
                  bmi = weight_kg/(height_m * height_m)
                  vitals << {
                    taken_at: weight_vital.taken_at,
                    value: bmi.round(1),
                    unit: "",
                    percentile: GrowthCurvesHelper.bmi_percentile(@patient.sex, @patient.birth_date.to_datetime, weight_vital.taken_at.to_datetime, (bmi.to_f).round(1))
                  }
                end
              end

              present :bmis, vitals, with: Leo::Entities::VitalEntity
            end
          end

          # get "patients/{patient_id}/allergies"
          desc "get allergies"
          get 'allergies' do
            allergies = Allergy.where(patient: @patient).order(:onset_at)
            present :allergies, allergies, with: Leo::Entities::AllergyEntity
          end

          # get "patients/{patient_id}/immunizations"
          desc "get immunizations"
          params do
            optional :response_type, type: String, values: ['pdf', 'json']
          end

          get 'immunizations' do
            immunizations = @patient.vaccines.order(:administered_at)
            if params[:response_type].nil? || params[:response_type] == 'json'
              present :immunizations, immunizations, with: Leo::Entities::VaccineEntity
            else
              content_type "application/pdf"
              env['api.format'] = :binary
              template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'vaccines', 'vaccines.html.erb'))
              if immunizations.count > 0
                output = template.render(@patient)
                WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
              else
                error!({error_code: 422, user_message: "Sorry, looks like you don't have any vaccines to export. Check back after your child's first visit" }, 422)
              end
            end
          end

          # get "patients/{patient_id}/vitals/medications"
          desc "get medications"
          get 'medications' do
            meds = Medication.where(patient: @patient, ended_at: nil).order(:started_at)
            present :medications, meds, with: Leo::Entities::MedicationEntity
          end

          namespace 'notes' do
            # get "patients/{patient_id}/notes"
            desc "get all notes"
            get do
              notes = UserGeneratedHealthRecord.where(patient: @patient, deleted_at: nil)
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
