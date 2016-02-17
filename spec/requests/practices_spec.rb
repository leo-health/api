require 'airborne'
require 'rails_helper'

describe Leo::V1::Practices do
  let!(:practice){ create(:practice) }
  let(:user){ create(:user, :guardian, practice: practice) }
  let!(:session){ user.sessions.create }

  describe "GET /api/v1/practices" do
    def do_request
      get "/api/v1/practices", { authentication_token: session.authentication_token }
    end

    it "should return all practices" do
      do_request
      expect(response.status).to eq(200)
      expect_json_sizes("data.practices", 1)
    end
  end

  describe "GET /api/v1/practices/:id" do
    def do_request
      get "/api/v1/practices/#{practice.id}", { authentication_token: session.authentication_token }
    end

    it "should return the individual practice" do
      do_request
      expect(response.status).to eq(200)
      expect_json("data.practice.id", practice.id)
    end
  end
end
