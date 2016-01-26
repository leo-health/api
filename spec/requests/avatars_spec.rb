require 'airborne'
require 'rails_helper'

describe Leo::V1::Avatars do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){create(:user, :guardian)}
  let(:session){user.sessions.create(device_type: 'iPhone 6')}
  let(:patient){create(:patient, family: user.family)}
  let!(:serializer){ Leo::Entities::AvatarEntity }

  describe "Post /api/v1/avatars" do
    def do_request
      avatar = open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}
      encoded_avatar = Base64.encode64(avatar)
      post "/api/v1/avatars", { authentication_token: session.authentication_token,
                                patient_id: patient.id,
                                avatar: encoded_avatar }
    end

    it "should create an avatar for the patient" do
      expect{ do_request }.to change{ Avatar.count }.from(0).to(1)
      expect(response.status).to eq(201)
    end
  end
end
