require 'airborne'
require 'rails_helper'

describe Leo::V1::Families do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let(:session){ user.sessions.create }
  let(:serializer){ Leo::Entities::FamilyEntity }

  describe "Get /api/v1/family" do
    def do_request(token)
      get "/api/v1/family", { authentication_token: token }
    end

    context "user is complete" do
      it "should return the members of the family" do
        do_request session.authentication_token
        expect(response.status).to eq(200)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:family].as_json.to_json).to eq(serializer.represent(user.reload.family).as_json.to_json)
      end
    end
  end

  describe "POST /api/v1/family/invite" do
    let!(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let!(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian)}

    def do_request
      enrollment_params = {
        email: 'wuang@leohealth.com',
        first_name: Faker::Name::first_name,
        last_name: Faker::Name::last_name,
        authentication_token: session.authentication_token
      }

      post "/api/v1/family/invite", enrollment_params
    end

    it "should send a invite to the user" do
      expect{ do_request }.to change{ Delayed::Job.count }.by(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:email]).to eq('wuang@leohealth.com')
      expect(body[:data][:onboarding_group].as_json.to_json).to eq(onboarding_group.as_json.to_json)
    end
  end

  describe "POST /api/v1/family/patients" do
    let(:patient_params1){
      {
        first_name: "patient_first_name1",
        last_name: "patient_last_name1",
        birth_date: 5.years.ago,
        sex: "M"
      }
    }
    let(:patient_params2){
      {
        first_name: "patient_first_name2",
        last_name: "patient_last_name2",
        birth_date: 5.years.ago,
        sex: "F"
      }
    }

    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }
    let(:authentication_token){ session.authentication_token }
    let(:patient_serializer){ Leo::Entities::PatientEntity }

    def do_request
      post("/api/v1/family/patients", {authentication_token: authentication_token, patients: [patient_params1, patient_params2]})
    end

    context "when patients don't exist" do
      it "creates patients" do
        expect{ do_request }.to change{ Patient.count }.by(2)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data][:patients]).to include(*patient_serializer.represent(user.family.patients).as_json)
      end
    end

    context "when a patient already exists" do
      before do
        user.family.patients.create(patient_params1)
      end

      it "updates the existing patient and creates one new patient" do
        expect{ do_request }.to change{ Patient.count }.by(1)
        body = JSON.parse(response.body, symbolize_names: true )
        expect(body[:data][:patients]).to include(*patient_serializer.represent(user.family.patients).as_json)
      end
    end
  end
end
