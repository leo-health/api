require 'rails_helper'

describe Leo::V1::Practices do
  let(:practice){ create(:practice) }
  let(:user){ create(:user, :guardian, practice: practice) }
  let!(:session){ user.sessions.create }
  let(:serializer){ Leo::Entities::PracticeEntity }

  describe "GET /api/v1/practices" do
    def do_request
      get "/api/v1/practices", { authentication_token: session.authentication_token }
    end

    it "should return all practices" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:practices].as_json.to_json).to eq(serializer.represent([practice]).as_json.to_json)
    end
  end

  describe "GET /api/v1/practices/current" do
    def do_request
      get "/api/v1/practices/current", { authentication_token: session.authentication_token }
    end

    it "should return the individual practice" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:practice].as_json.to_json).to eq(serializer.represent(user.practice).as_json.to_json)
    end
  end
end
