require 'rails_helper'

describe Leo::V1::IosConfiguration do
  describe "GET /api/v1/ios_configuration" do
    it "should return the ios configuration" do
      get "/api/v1/ios_configuration"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data].length).to eq(3)
    end
  end
end
