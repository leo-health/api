require 'rails_helper'

describe Leo::V1::DeepLinks do
  describe "Get /api/v1/deep_link" do
    context "when access from iphone" do
      def do_request
        get "/api/v1/deep_link", { type: 'conversation', type_id: 1 },
            { "HTTP_USER_AGENT" => "Mozilla/5.0 (iPhone; CPU iPhone OS 9_2_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13D15 Safari/601.1" }
      end

      it "should redirect to a deeplink" do
        do_request
        expect(response.status).to eq(301)
        expect(response.header['Location']).to eq( "#{ENV['DEEPLINK_SCHEME']}://feed/conversation/1" )
      end
    end

    context "access from other than iphone" do
      def do_request
        get "/api/v1/deep_link", { type: 'conversation', type_id: 1 }
      end

      it "should redirect to a url" do
        do_request
        expect(response.status).to eq(301)
        expect(response.header['Location']).to eq("http://localhost:8888/#/invalid-device")
      end
    end
  end
end
