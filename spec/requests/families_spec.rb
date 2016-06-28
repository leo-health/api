require 'airborne'
require 'rails_helper'

describe Leo::V1::Families do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let(:session){ user.sessions.create }
  let(:patient){ create(:patient, family: user.family) }
  let!(:patient_avatar){create(:avatar, owner: patient)}
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
      enrollment_params = { email: Faker::Internet::email, first_name: Faker::Name::first_name, last_name: Faker::Name::last_name }
      enrollment_params.merge!(authentication_token: session.authentication_token)
      post "/api/v1/family/invite", enrollment_params
    end

    it "should send a invite to the user" do
      expect{ do_request }.to change{ Delayed::Job.count }.by(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:onboarding_group].to_sym).to eq(:invited_secondary_guardian)
      expect(user.family.reload.guardians.count).to be(1)
    end
  end
end
