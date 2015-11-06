require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  get "/api/v1/staff" do
    parameter :authentication_token, "Authentication Token", :required => true

    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }
    let!(:clinical){ create(:user, :clinical) }
    let(:authentication_token){ session.authentication_token }
    let(:serializer){ Leo::Entities::UserEntity }

    let(:raw_post){ params.to_json }

    example "get all staff" do
      do_request
      expect(response_status).to eq(200)
      body = JSON.parse(response_body, symbolize_names: true )
      expect(body[:data][:staff].as_json.to_json).to eq(serializer.represent([clinical]).as_json.to_json)
    end
  end
end
