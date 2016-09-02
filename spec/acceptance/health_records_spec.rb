require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "HealthRecords" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }

  get "/api/v1/patients/:id/phr" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }

    let!(:weights) {
      [
        create(:vital, :weight, patient_id: patient.id, taken_at: 0.days.ago),
        create(:vital, :weight, patient_id: patient.id, taken_at: 1.day.ago),
        create(:vital, :weight, patient_id: patient.id, taken_at: 2.days.ago)
      ]
    }

    let!(:heights) {
      [
        create(:vital, :height, patient_id: patient.id, taken_at: 0.days.ago),
        create(:vital, :height, patient_id: patient.id, taken_at: 1.day.ago),
        create(:vital, :height, patient_id: patient.id, taken_at: 2.days.ago)
      ]
    }

    let!(:allergies) {
      [
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id)
      ]
    }

    let!(:medications) {
      [
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id, ended_at: DateTime.now)
      ]
    }

    let!(:immunizations) {
      [
        create(:vaccine, patient_id: patient.id),
        create(:vaccine, patient_id: patient.id),
        create(:vaccine, patient_id: patient.id),
        create(:vaccine, patient_id: patient.id)
      ]
    }

    example "get phr" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/vitals/height" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :start_date, "Start date for the vitals search", required: true
    parameter :end_date, "End date for the vitals search", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:start_date) { 10.years.ago.strftime("%m/%d/%Y") }
    let(:end_date) { DateTime.now.strftime("%m/%d/%Y") }
    let(:raw_post){ params.to_json }

    let!(:heights) {
      [
        create(:vital, :height, patient_id: patient.id),
        create(:vital, :height, patient_id: patient.id),
        create(:vital, :height, patient_id: patient.id)
      ]
    }

    example "get all patient height vitals" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/vitals/weight" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :start_date, "Start date for the vitals search", required: true
    parameter :end_date, "End date for the vitals search", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:start_date) { 10.years.ago.strftime("%m/%d/%Y") }
    let(:end_date) { DateTime.now.strftime("%m/%d/%Y") }
    let(:raw_post){ params.to_json }

    let!(:weights) {
      [
        create(:vital, :weight, patient_id: patient.id),
        create(:vital, :weight, patient_id: patient.id),
        create(:vital, :weight, patient_id: patient.id)
      ]
    }

    example "get all patient weight vitals" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/vitals/bmis" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :start_date, "Start date for the vitals search", required: true
    parameter :end_date, "End date for the vitals search", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:start_date) { 10.years.ago.strftime("%m/%d/%Y") }
    let(:end_date) { DateTime.now.strftime("%m/%d/%Y") }
    let(:raw_post){ params.to_json }

    let!(:weights) {
      [
        create(:vital, :weight, patient_id: patient.id, taken_at: 0.days.ago),
        create(:vital, :weight, patient_id: patient.id, taken_at: 1.day.ago),
        create(:vital, :weight, patient_id: patient.id, taken_at: 2.days.ago)
      ]
    }

    let!(:heights) {
      [
        create(:vital, :height, patient_id: patient.id, taken_at: 0.days.ago),
        create(:vital, :height, patient_id: patient.id, taken_at: 1.day.ago),
        create(:vital, :height, patient_id: patient.id, taken_at: 2.days.ago)
      ]
    }

    example "get all patient bmi vitals" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/allergies" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }

    let!(:allergies) {
      [
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id)
      ]
    }

    example "get all patient allergies" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/medications" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }

    let!(:medications) {
      [
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id, ended_at: DateTime.now)
      ]
    }

    example "get all patient medications" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/immunizations" do
    parameter :authentication_token, required: true
    parameter :response_type, 'pdf or json', required: true
    parameter :id, "Patient Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:response_type) { 'pdf' }
    let(:raw_post){ params.to_json }

    before do
      4.times{ create(:vaccine, patient_id: patient.id) }
    end

    example "get all patient immunizations" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/notes" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }

    let!(:notes) {
      [
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user, deleted_at: DateTime.now)
      ]
    }

    example "get all patient notes" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/patients/:id/notes/:note_id" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :note_id, "Note Id", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:raw_post){ params.to_json }
    let!(:note) { create(:user_generated_health_record, patient: patient, user: user) }
    let(:note_id) { note.id }

    example "get a specific patient note" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/patients/:id/notes" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :note, "Note Text", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:note) { "Note text" }
    let(:raw_post){ params.to_json }

    example "create a new patient note" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  put "/api/v1/patients/:id/notes/:note_id" do
    parameter :authentication_token, required: true
    parameter :id, "Patient Id", required: true
    parameter :note_id, "Note Id", required: true
    parameter :note, "Note Text", required: true

    let(:authentication_token) { session.authentication_token }
    let(:id) { patient.id }
    let(:note) { "New note text" }
    let!(:existing_note) { create(:user_generated_health_record, patient: patient, user: user) }
    let(:note_id) { existing_note.id }
    let(:raw_post){ params.to_json }

    example "update an existing note" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
