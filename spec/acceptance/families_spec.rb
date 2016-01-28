require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Families" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  get "/api/v1/family" do
    parameter :authentication_token, 'Authentication Token', required: true

    let(:user){ create(:user, :guardian) }
    let!(:session){ user.sessions.create }
    let!(:patient){ create(:patient, family: user.family) }
    let(:authentication_token){ session.authentication_token }
    let(:raw_post){ params.to_json }

    example "get members of a family" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
