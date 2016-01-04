require 'airborne'
require 'rails_helper'

describe Leo::V1::Forms do
  let(:serializer){ Leo::Entities::FormEntity }
  let(:user){ create(:user) }
  let(:patient){ create(:patient, family: user.family) }
  let(:form){ create(:form, patient: patient, submitted_by: user) }
  let(:session){ user.sessions.create }

  describe "Post /api/v1/forms" do
    def do_request
      form = open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}
      encoded_form = Base64.encode64(form)
      form_params = { patient_id: patient.id,
                      title: "test",
                      image: encoded_form,
                      submitted_by_id: user.id
                    }

      post "/api/v1/forms", form_params.merge!( authentication_token: session.authentication_token )
    end

    it "should create a form" do
      do_request
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:form].as_json.to_json).to eq(serializer.represent(Form.first).as_json.to_json)
    end
  end

  describe "Get /api/v1/forms/:id" do
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
    def do_request
      delete "/api/v1/forms/#{form.id}", { authentication_token: session.authentication_token }
    end

    it "should soft-delete a form" do
      do_request
      expect(response.status).to eq(200)
      expect(form.reload.deleted_at).not_to eq(nil)
    end
  end

  describe "Put /api/v1/forms/:id" do

  end
end
