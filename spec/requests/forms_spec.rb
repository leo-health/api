require 'airborne'
require 'rails_helper'

describe Leo::V1::Forms do
  let(:serializer){ Leo::Entities::FormEntity }

  describe "Post /api/v1/forms" do
    it "should create a form"
  end

  describe "Get /api/v1/forms/:id" do
    let(:user){ create(:user) }
    let(:patient){ create(:patient, family: user.family) }
    let(:form){ create(:form, patient: patient, submitted_by: user) }
    let(:session){ user.sessions.create }

    def do_request
      get "/api/v1/forms/#{form.id}", { authentication_token: session.authentication_token }
    end

    it "should update the form" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:form].as_json.to_json).to eq(serializer.represent(form.reload).as_json.to_json)
    end
  end

  describe "Delete /api/v1/forms/:id" do
    it "should soft-delete a form"
  end

  describe "Put /api/v1/forms/:id" do

  end
end
