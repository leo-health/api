require 'airborne'
require 'rails_helper'

describe Leo::V1::Roles do
  describe "GET /api/v1/roles" do
    let!(:guardian){create(:role, :guardian)}
    let!(:patient){create(:role, :patient)}

    def do_request
      get '/api/v1/roles', format: :json
    end

    it "returns all roles" do
      do_request
      expect(response.status).to eq(200)
      expect_json([guardian, patient].as_json)
    end
  end
end
