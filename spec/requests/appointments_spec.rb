require 'airborne'
require 'rails_helper'

describe Leo::V1::Appointments do
  let(:user){ create(:user, :guardian) }
  let!(:session){ user.sessions.create }

  describe "Post /api/v1/appointments" do
    let!(:appointment_type){ create(:appointment_type)}
    let!(:provider){create(:user, :clinical)}
    let!(:patient){create(:patient, family: user.family)}

    def do_request
      appointment_params = { duration: 30,
                             start_datetime: Time.now,
                             status_id: 1,
                             status: "Future",
                             appointment_type_id: appointment_type.id,
                             provider_id: provider.id,
                             patient_id: patient.id
                           }
      post "/api/v1/appointments", appointment_params.merge({authentication_token: session.authentication_token})
    end

    it "should create an appointment" do
      do_request
      expect(response.status).to eq(201)
      expect_json("data.appointment.booked_by.id", user.id)
      expect_json("data.appointment.patient.id", patient.id)
      expect_json("data.appointment.provider.id", provider.id)
    end
  end

  describe "Get /api/v1/appointments/:id" do
    let!(:appointment){create(:appointment, booked_by: user)}

    def do_request
      get "/api/v1/appointments/#{appointment.id}", {authentication_token: session.authentication_token}
    end

    it "should show an appointment" do
      do_request
      expect(response.status).to eq(200)
      expect_json("data.appointment.id", appointment.id)
    end
  end

  describe "Delete /api/v1/appointments" do
    let!(:appointment){create(:appointment, booked_by: user)}

    def do_request
      delete "/api/v1/appointments", {authentication_token: session.authentication_token, id: appointment.id}
    end

    it "should delete the requested appointment" do
      expect{ do_request }.to change{ Appointment.count }.from(1).to(0)
      expect(response.status).to eq(200)
    end
  end

  describe "Get /api/v1/appointments" do
    let!(:appointment){create(:appointment, booked_by: user)}
    let!(:other_appointment){create(:appointment, booked_by: user)}

    def do_request
      get "/api/v1/appointments", {authentication_token: session.authentication_token}
    end

    it "should return all the appointments of the user" do
      do_request
      expect(response.status).to eq(200)
      expect_json_sizes("data.appointments", 2)
    end
  end
end
