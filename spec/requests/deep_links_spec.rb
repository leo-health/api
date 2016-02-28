require 'rails_helper'

describe Leo::V1::DeepLinks do
  describe "Get /api/v1/deep_link" do

    def do_request
      get "/api/v1/deep_link", { type: 'conversation', type_id: 1 }, { "HTTP_USER_AGENT": "iPhone" }
      byebug
    end

    context "when access from iphone" do
      it "should redirect to a deeplink" do
        expect(response.status).to eq(301)
        byebug
      end
    end

    context "access from other than iphone" do
      it "should redirect to a url" do
        expect(response.status).to eq(301)
      end
    end
  end
end
