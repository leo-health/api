require 'airborne'
require 'rails_helper'
require 'stripe_mock'

describe Leo::V1::Patients do
  before do
    Stripe.api_key="test_key"
    StripeMock.start
    stripe_helper.create_plan(STRIPE_PLAN_PARAMS_MOCK)
  end

  after do
    StripeMock.stop
  end

  let!(:stripe_helper) { StripeMock.create_test_helper }
  let!(:guardian){create(:user, :member)}
  let!(:second_guardian){ create(:user, family: guardian.family) }
  let!(:session){guardian.sessions.create}
  let!(:serializer){ Leo::Entities::PatientEntity }
  let!(:patient){create(:patient, family: guardian.family)}

  describe 'POST /api/v1/patients' do
    before do
      Delayed::Job.destroy_all
    end

    let(:patient_params){{first_name: "patient_first_name",
                          last_name: "patient_last_name",
                          birth_date: 5.years.ago,
                          sex: "M"
                        }}

    def do_request(a_session)
      patient_params.merge!({authentication_token: a_session.authentication_token})
      post "/api/v1/patients", patient_params, format: :json
    end

    def expect_patient_to_be_added(family, a_session)
      do_request a_session
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      patient_id = body[:data][:patient][:id]
      expect(body[:data][:patient].as_json.to_json).to eq(serializer.represent(Patient.find(patient_id)).as_json.to_json)
      expect(family.reload.patients.count).to be(2)
    end

    context "family is a member" do
      it "should add a patient to the family" do
        expect_patient_to_be_added guardian.family, session
      end

      it "should add a patient to the family, update the subscription, and send an email to all guardians" do
        expect_any_instance_of(Stripe::Invoice).to receive(:pay)
        expect_patient_to_be_added guardian.family, session
        expect(guardian.family.reload.stripe_subscription[:quantity]).to be(2)
        jobs = Delayed::Job.where(queue: PaymentsMailer.queue_name)
        expect(jobs.count).to be(2)
        expect(jobs.pluck(:owner_id).sort).to eq(guardian.family.reload.guardians.pluck(:id).sort)
      end
    end

    context "family is incomplete" do
      let!(:incomplete_guardian){ create(:user) }
      let!(:incomplete_session){ incomplete_guardian.sessions.create }
      let!(:incomplete_patient){ create(:patient, family: incomplete_guardian.family) }

      it "should add a patient to the family" do
        expect_patient_to_be_added incomplete_guardian.family, incomplete_session
        expect(incomplete_guardian.family.reload.stripe_subscription).to be_nil
        expect(Delayed::Job.where(queue: PaymentsMailer.queue_name).count).to be(0)
      end
    end

    context "family is exempt" do
      let!(:exempt_guardian){ create(:user) }
      let!(:exempt_session){ exempt_guardian.sessions.create }
      let!(:exempt_patient){ create(:patient, family: exempt_guardian.family) }

      before do
        exempt_guardian.family.exempt_membership!
      end

      it "should add a patient to the family" do
        expect_patient_to_be_added exempt_guardian.family, exempt_session
        expect(exempt_guardian.family.reload.stripe_subscription).to be_nil
        expect(Delayed::Job.where(queue: PaymentsMailer.queue_name).count).to be(0)
      end
    end
  end

  describe 'Delete /api/v1/patients/:id' do
    def do_request
      delete "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should delete the indivial patient record, guardian only' do
      expect{do_request}.to change{ Patient.count }.from(1).to(0)
      expect(response.status).to eq(200)
    end
  end

  describe 'Put /api/v1/patients/:id' do
    let(:new_email){ "new_email@leohealth.com" }

    def do_request
      put "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token, email: new_email}
    end

    it 'should update the individual patient record, guardian only' do
      do_request
      original_email = patient.email
      expect(response.status).to eq(200)
      expect{patient.reload}.to change{patient.email}.from(original_email).to(new_email)
    end
  end

  describe "Get /api/v1/patients/:id" do
    def do_request
      get "/api/v1/patients/#{patient.id}", {authentication_token: session.authentication_token}
    end

    it 'should show the patient' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patient].as_json.to_json).to eq(serializer.represent(patient).as_json.to_json)
    end
  end

  describe "Get /api/v1/patients" do
    def do_request
      get "/api/v1/patients", {authentication_token: session.authentication_token}
    end

    it 'should show the patients' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:patients].as_json.to_json).to eq(serializer.represent(Patient.all).as_json.to_json)
    end
  end
end
