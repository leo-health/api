require 'rails_helper'

describe Leo::V1::IosConfiguration do
  describe "GET /api/v1/validated_json" do
    it "should return valid json or an error" do
      allow(Net::HTTP).to receive(:get).and_return("{
          \"data\": {
            \"text\": \"Welcome to Leo + Flatiron Pediatrics. Say hello. Book an appointment. Review your child's health record.\"
          }
        }
      ")
      get "/api/v1/validated_json", {source: "http://somefakeurl.com/test"}

      byebug
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:data][:text]).to eq("Welcome to Leo + Flatiron Pediatrics. Say hello. Book an appointment. Review your child's health record.")
    end
  end
end
