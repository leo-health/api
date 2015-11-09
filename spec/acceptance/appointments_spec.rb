require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Appointments" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:authentication_token){ session.authentication_token }
  let(:appointment_status){ create(:appointment_status)}
  let(:appointment_type){ create(:appointment_type)}
  let(:provider){create(:user, :clinical)}
  let(:patient){create(:patient, family: user.family)}
  let(:practice){create(:practice)}
  let(:appointment){create(:appointment, booked_by: user)}

  post "/api/v1/appointments" do
    parameter :authentication_token, :required => true
    parameter :start_datetime, :required => true
    parameter :appointment_status_id, :required => true
    parameter :appointment_type_id, :required => true
    parameter :provider_id, :required => true
    parameter :patient_id, :required => true
    parameter :practice_id, :required => true
    parameter :notes
    parameter :athena_id

    let(:start_datetime){ Time.now }
    let(:appointment_status_id){ appointment_status.id }
    let(:appointment_type_id){ appointment_type.id }
    let(:provider_id){ provider.id }
    let(:patient_id){ patient.id }
    let(:practice_id){ practice.id }
    let(:raw_post){ params.to_json }

    example "create an appointment" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  get "/api/v1/appointments/:id" do
    parameter :id, "appointment id", :required => true
    parameter :authentication_token, :required => true

    let(:id){ appointment.id }
    let(:raw_post){ params.to_json }

    example "get an appointment" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  delete "/api/v1/appointments/:id" do
    parameter :id, "appointment id", :required => true
    parameter :authentication_token, :required => true

    let(:id){ appointment.id }
    let(:raw_post){ params.to_json }

    example "delete an appointment" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/appointments/:id" do
    parameter :id, "appointment id", :required => true
    parameter :authentication_token, :required => true
    parameter :start_datetime, :required => true
    parameter :appointment_status_id, :required => true
    parameter :appointment_type_id, :required => true
    parameter :provider_id, :required => true
    parameter :patient_id, :required => true
    parameter :practice_id, :required => true
    parameter :notes
    parameter :athena_id

    let(:id){ appointment.id }
    let(:start_datetime){ Time.now }
    let(:appointment_status_id){ appointment_status.id }
    let(:appointment_type_id){ appointment_type.id }
    let(:provider_id){ provider.id }
    let(:patient_id){ patient.id }
    let(:practice_id){ practice.id }
    let(:raw_post){ params.to_json }

    example "get an appointment" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/appointments" do
    parameter :authentication_token, :required => true

    example "get all appointments of current user" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
