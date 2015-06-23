require 'airborne'
require 'rails_helper'

describe Leo::Roles do
  describe "GET /api/v1/roles" do
    let!(:parent){create(:role, :parent)}
    let!(:child){create(:role, :child)}

    def do_request
      get '/api/v1/roles', format: :json
    end

    it "returns all roles" do
      do_request
      expect(response.status).to eq(200)
      expect_json([parent, child].as_json)
    end
  end
end
