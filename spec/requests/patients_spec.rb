require 'airborne'
require 'rails_helper'

describe Leo::V1::Patients do
  describe 'GET /api/v1/users/:id/patients' do
    let!(:family){create(:family_with_members)}
    let(:guardian){Role.find_by_name("guardian").users.first}
    # let!(:session){guardian.sessions.create}

    def do_request
      get "/api/v1/users/#{guardian.id}/patients", {authentication_token: session.authentication_token}
    end

    it "should return every patients belongs to the guardian" do
      byebug
      do_request
      byebug
      expect(response.status).to eq(200)
      expect_json(Role.find_by_name('patients').users)
    end
  end

  describe 'POST /api/v1/users/:user_id/patients' do
    let(:guardian){create(:user, :father)}
    let!(:session){guardian.sessions.create}

    def do_request
      @patient_params = FactoryGirl.attributes_for(:user, :child).merge({authentication_token: session.authentication_token})
      post "/api/v1/users/patients", @patient_params, format: :json
    end

    it "should add a child to the family" do
      do_request
      expect(response.status).to eq(201)
      expect_json('data.patient.first_name', @child_params[:first_name])
      expect_json('data.patient.last_name', @child_params[:last_name])
    end
  end

  describe 'Delete /api/v1/users/id/patients' do

  end

  describe  do

  end
end
