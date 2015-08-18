require 'airborne'
require 'rails_helper'

describe Leo::V1::Conversations do
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }
  let!(:patient){ create(:patient, family: user.family) }
  let!(:serializer){ Leo::Entities::FamilyEntity }

  describe "Get /api/v1/family" do
    def do_request
      get "/api/v1/family", { authentication_token: session.authentication_token }
    end

    it "should return the members of the family" do
      do_request
      expect(response.status).to eq(200)
      expect_json("data.family", serializer.represent(user.family).as_json)
    end
  end
end
