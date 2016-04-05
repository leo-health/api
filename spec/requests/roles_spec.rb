require 'rails_helper'

describe Leo::V1::Roles do
  describe "GET /api/v1/roles" do
    let(:user){ create(:user, :guardian) }
    let(:session){ user.sessions.create }
    let(:serializer){ Leo::Entities::RoleEntity }

    def do_request
      get '/api/v1/roles', { authentication_token: session.authentication_token }
    end

    it "returns all roles" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:roles].as_json.to_json).to eq(serializer.represent(Role.all).as_json.to_json)
    end
  end
end
