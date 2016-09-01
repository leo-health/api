require 'airborne'
require 'rails_helper'

describe Leo::V1::Vaccines do
  let(:user){create(:user, :guardian)}
  let(:session){ user.sessions.create }

  describe "GET /api/v1/:patient_id/vaccines" do
    def do_request
      get "/api/v1/#{patient.id}/vaccines", { authentication_token: session.authentication_token }
    end

    context "guardian and patient belongs to same family" do
      let!(:patient){ create(:patient, family: user.family) }
      let!(:vaccine){ create(:vaccine, patient: patient) }

      it "should return vaccines form in pdf format" do
        do_request
        expect(response.status).to eq(200)
      end
    end

    context "guardian and patient not belongs to same family" do
      let!(:patient){ create :patient }

      it "should not return vaccine records" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end
end
