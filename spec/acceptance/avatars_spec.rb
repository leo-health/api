require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Messages" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create(device_type: 'iPhone 6') }
  let(:authentication_token){ session.authentication_token }
  let(:patient){ create(:patient, family: user.family)}

  post "/api/v1/avatars" do
    parameter :authentication_token, "Authentication Token", required: true
    parameter :patient_id, "Patient Id", required: true
    parameter :avatar, "Base64 Encoded Avatar", required: true

    let(:raw_post){ params.to_json }

    example "create an avatar for patient" do
      image = open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}
      encoded_image = Base64.encode64(image)
      do_request(authentication_token: session.authentication_token, avatar: encoded_image, patient_id: patient.id)
      expect(response_status).to eq(201)
    end
  end
end
