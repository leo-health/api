require 'airborne'
require 'rails_helper'
require 'csv'

describe Leo::V1::HealthRecords do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }

  describe "GET /api/v1/patients/:id/phr" do
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

    def do_request
      get "/api/v1/patients/#{patient.id}/phr", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return full phr" do
      do_request
      expect(response.status).to eq(200)
    end
  end

  describe "GET /api/v1/patients/:id/vitals/height" do
    let!(:heights) {
      [
        create(:vital, :height, patient_id: patient.id, value: 27.9399),
        create(:vital, :height, patient_id: patient.id, value: 30.4799),
        create(:vital, :height, patient_id: patient.id, value: 33.0200),
        create(:vital, :height, patient_id: patient.id, value: 63.4999),
        create(:vital, :height, patient_id: patient.id, value: 63.8123)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/vitals/height", { authentication_token: session.authentication_token, start_date: 10.years.ago.strftime("%m/%d/%Y"), end_date: DateTime.now.strftime("%m/%d/%Y") }, format: :json
    end

    it "should return a list of heights" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)

      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)

      heights = resp["data"]["heights"].sort_by {|height| height["value"]}
      expect(heights.size).to eq(5)

      expect(heights[0]["formatted_value_with_units"]).to eq("11 in")
      expect(heights[0]["formatted_values"]).to eq([11])
      expect(heights[0]["formatted_units"]).to eq(["in"])
      expect(heights[1]["formatted_value_with_units"]).to eq("1 ft 0 in")
      expect(heights[1]["formatted_values"]).to eq([1, 0])
      expect(heights[1]["formatted_units"]).to eq(["ft", "in"])
      expect(heights[2]["formatted_value_with_units"]).to eq("1 ft 1 in")
      expect(heights[2]["formatted_values"]).to eq([1, 1])
      expect(heights[2]["formatted_units"]).to eq(["ft", "in"])
      expect(heights[3]["formatted_value_with_units"]).to eq("2 ft 1 in")
      expect(heights[3]["formatted_values"]).to eq([2, 1])
      expect(heights[3]["formatted_units"]).to eq(["ft", "in"])
      expect(heights[4]["formatted_value_with_units"]).to eq("2 ft 1 in")
      expect(heights[4]["formatted_values"]).to eq([2, 1])
      expect(heights[4]["formatted_units"]).to eq(["ft", "in"])
    end
  end

  describe "GET /api/v1/patients/:id/vitals/weight" do
    let!(:weights) {
      [
        create(:vital, :weight, patient_id: patient.id, value: 424.771),
        create(:vital, :weight, patient_id: patient.id, value: 453.5929),
        create(:vital, :weight, patient_id: patient.id, value: 10560),
        create(:vital, :weight, patient_id: patient.id, value: 11113.02),
        create(:vital, :weight, patient_id: patient.id, value: 11821.7649)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/vitals/weight", { authentication_token: session.authentication_token, start_date: 10.years.ago.strftime("%m/%d/%Y"), end_date: DateTime.now.strftime("%m/%d/%Y") }, format: :json
    end

    it "should return a list of weights" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)

      weights = resp["data"]["weights"].sort_by {|weight| weight["value"]}
      expect(weights.size).to eq(5)

      expect(weights[0]["formatted_value_with_units"]).to eq("15 oz")
      expect(weights[0]["formatted_values"]).to eq([15])
      expect(weights[0]["formatted_units"]).to eq(["oz"])
      expect(weights[1]["formatted_value_with_units"]).to eq("1 lb 0 oz")
      expect(weights[1]["formatted_values"]).to eq([1, 0])
      expect(weights[1]["formatted_units"]).to eq(["lb", "oz"])
      expect(weights[2]["formatted_value_with_units"]).to eq("23 lbs 5 oz")
      expect(weights[2]["formatted_values"]).to eq([23, 5])
      expect(weights[2]["formatted_units"]).to eq(["lbs", "oz"])
      expect(weights[3]["formatted_value_with_units"]).to eq("24 lbs 8 oz")
      expect(weights[3]["formatted_values"]).to eq([24, 8])
      expect(weights[3]["formatted_units"]).to eq(["lbs", "oz"])
      expect(weights[4]["formatted_value_with_units"]).to eq("26 lbs 1 oz")
      expect(weights[4]["formatted_values"]).to eq([26, 1])
      expect(weights[4]["formatted_units"]).to eq(["lbs", "oz"])
    end
  end

  describe "GET /api/v1/patients/:id/vitals/bmis" do
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

    def do_request
      get "/api/v1/patients/#{patient.id}/vitals/bmis", { authentication_token: session.authentication_token, start_date: 10.years.ago.strftime("%m/%d/%Y"), end_date: DateTime.now.strftime("%m/%d/%Y") }, format: :json
    end

    it "should return a list of bmis" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["bmis"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/allergies" do
    let!(:allergies) {
      [
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id),
        create(:allergy, patient_id: patient.id)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/allergies", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of allergies" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["allergies"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/medications" do
    let!(:medications) {
      [
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id),
        create(:medication, patient_id: patient.id, ended_at: DateTime.now)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/medications", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of medications" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["medications"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/immunizations" do
    before do
      4.times{create(:vaccine, patient: patient)}
    end

    context 'when request json format response' do
      def do_request
        get "/api/v1/patients/#{patient.id}/immunizations", { authentication_token: session.authentication_token}
      end

      it "should return a list of immunizations" do
        do_request
        expect(response.status).to eq(200)
        resp = JSON.parse(response.body)
        expect(resp["data"]["immunizations"].size).to eq(4)
      end
    end

    context 'when request pdf format response' do
      def do_request
        get "/api/v1/patients/#{patient.id}/immunizations", { authentication_token: session.authentication_token,  response_type: 'pdf'}
      end

      it "should return a list of immunizations" do
        do_request
        expect(response.status).to eq(200)
        expect(response.body.class).to eq(String)
      end
    end
  end

  describe "GET /api/v1/patients/:id/notes" do
    let!(:notes) {
      [
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user),
        create(:user_generated_health_record, patient: patient, user: user, deleted_at: DateTime.now)
      ]
    }

    def do_request
      get "/api/v1/patients/#{patient.id}/notes", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a list of notes" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["notes"].size).to eq(3)
    end
  end

  describe "GET /api/v1/patients/:id/notes/:note_id" do
    let!(:note) { create(:user_generated_health_record, patient: patient, user: user) }

    def do_request
      get "/api/v1/patients/#{patient.id}/notes/#{note.id}", { authentication_token: session.authentication_token }, format: :json
    end

    it "should return a requested note" do
      do_request
      expect(response.status).to eq(200)
      resp = JSON.parse(response.body)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["note"]["id"]).to eq(note.id)
    end
  end

  describe "POST /api/v1/patients/:id/notes" do
    def do_request
      post "/api/v1/patients/#{patient.id}/notes", { authentication_token: session.authentication_token, note: "note text" }, format: :json
    end

    it "should create a note" do
      do_request
      expect(response.status).to eq(201)
    end
  end

  describe "PUT /api/v1/patients/:id/notes/:note_id" do
    let!(:note) { create(:user_generated_health_record, patient: patient, user: user) }

    def do_request
      put "/api/v1/patients/#{patient.id}/notes/#{note.id}", { authentication_token: session.authentication_token, note: "note text 2" }, format: :json
    end

    it "update a note" do
      do_request
      resp = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(resp["status"]).to eq("ok")
      expect(resp["data"].size).to eq(1)
      expect(resp["data"]["note"]["note"]).to eq("note text 2")
    end
  end
end
