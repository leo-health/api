require 'rails_helper'

describe Leo::V1::StaffProfiles do
  describe 'PUT /api/v1/staff_profiles/current' do
    def do_request(staff_profile_params)
      put "/api/v1/staff_profiles/current", staff_profile_params, format: :json
    end

    context 'user is a guardian' do
      let(:user){ create(:user) }
      let(:session){ user.sessions.create }

      it 'should return a 401 error' do
        do_request({authentication_token: session.authentication_token})
        expect(response.status).to eq(401)
      end
    end

    context 'user do not have correct email and password' do
      let(:user){ create(:user, :clinical) }
      let(:session){ user.sessions.create }
      let!(:staff_profile){ create(:staff_profile, staff: user)}

      it 'should not create session and return error message' do
        expect( staff_profile.on_call ).to eq(false)
        do_request({authentication_token: session.authentication_token, on_call: true})
        expect(response.status).to eq(200)
        expect( staff_profile.reload.on_call ).to eq(true)
      end
    end
  end
end
