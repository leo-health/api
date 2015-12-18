require 'airborne'
require 'rails_helper'

describe Leo::V1::Families do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }
  let(:serializer){ Leo::Entities::FamilyEntity }

  describe "Get /api/v1/family" do
    def do_request
      get "/api/v1/family", { authentication_token: session.authentication_token }
    end

    it "should return the members of the family" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:family].as_json.to_json).to eq(serializer.represent(user.reload.family).as_json.to_json)
    end
  end
end
