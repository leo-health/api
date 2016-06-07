require 'rails_helper'

describe Leo::V1::IosConfiguration do
  describe "GET /api/v1/validated_json" do
    context "source returns valid json" do
      it "should redirect to the source" do
        allow(Net::HTTP).to receive(:get_response).and_return(Struct.new(:code, :body).new('200', "{
            \"data\": {
              \"text\": \"Welcome to Leo + Flatiron Pediatrics. Say hello. Book an appointment. Review your child's health record.\"
            }
          }
        "))
        get "/api/v1/validated_json", {source: "http://somefakeurl.com/test"}
        expect(response.status).to eq(302)
      end
    end

    context "source returns invalid json" do
      it "should return an error" do
        allow(Net::HTTP).to receive(:get_response).and_return(Struct.new(:code, :body).new('200', "{
            \"data\": {
              text\": \"Welcome to Leo + Flatiron Pediatrics. Say hello. Book an appointment. Review your child's health record.\"
        "))
        get "/api/v1/validated_json", {source: "http://somefakeurl.com/test"}
        expect(response.status).to eq(422)
      end
    end
  end
end
