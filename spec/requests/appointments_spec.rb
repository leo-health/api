require 'airborne'
require 'rails_helper'

describe Leo::V1::Appointments do
  let!(:customer_service){ create(:user, :customer_service) }
  let(:user){ create(:user, :guardian) }
  let(:session){ user.sessions.create }
  let(:serializer){ Leo::Entities::AppointmentEntity }
  let(:appointment_type){ create(:appointment_type)}
  let!(:cancelled_appointment_status){ create(:appointment_status, :cancelled) }
  let(:provider){create(:provider)}
  let(:patient){create(:patient, family: user.family)}
  let(:practice){create(:practice)}

  describe "Post /api/v1/appointments" do
    def do_request(appointment_params)
      post "/api/v1/appointments", appointment_params.merge({authentication_token: session.authentication_token})
    end

    it "creates an appointment" do
      appointment_params = { start_datetime: Time.now + Appointment::MIN_INTERVAL_TO_SCHEDULE + 1.minute,
                             appointment_status_id: cancelled_appointment_status.id,
                             appointment_type_id: appointment_type.id,
                             provider_id: provider.id,
                             patient_id: patient.id,
                             practice_id: practice.id
      }
      expect{ do_request(appointment_params) }.to change{ Delayed::Job.where(queue: PostAppointmentJob.queue_name).count }.by(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointment].as_json.to_json).to eq(serializer.represent(Appointment.first).as_json.to_json)
    end
  end

  describe "Get /api/v1/appointments/:id" do
    let!(:appointment){create(:appointment, booked_by: user)}

    def do_request
      get "/api/v1/appointments/#{appointment.id}", {authentication_token: session.authentication_token}
    end

    it "shows an appointment" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointment].as_json.to_json).to eq(serializer.represent(appointment.reload).as_json.to_json)
    end
  end

  describe "Delete /api/v1/appointments/:id" do
    let!(:appointment){ create(:appointment, booked_by: user) }

    def do_request
      delete "/api/v1/appointments/#{appointment.id}", {authentication_token: session.authentication_token}
    end

    it "changes the status of requested appointment to cancelled" do
      expect{ do_request }.to change{ Delayed::Job.where(queue: PostAppointmentJob.queue_name).count }.by(1)
      expect(response.status).to eq(200)
      expect(appointment.reload.cancelled?).to eq(true)
    end
  end

  describe "Get /api/v1/appointments" do
    let!(:appointment){create(:appointment, booked_by: user)}
    let!(:other_appointment){create(:appointment, booked_by: user)}

    def do_request
      get "/api/v1/appointments", {authentication_token: session.authentication_token}
    end

    it "returns all the appointments of the user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointments].as_json.to_json).to eq(serializer.represent([appointment.reload, other_appointment.reload]).as_json.to_json)
    end
  end

  describe "Put /api/v1/appointments/:id" do
    let!(:appointment){create(:appointment, booked_by: user)}

    def do_request(appointment_params)
      put "/api/v1/appointments/#{appointment.id}", appointment_params.merge({authentication_token: session.authentication_token})
    end

    it "cancels old appointment, and create a new appointment" do
      appointment_params = { start_datetime: Time.now + Appointment::MIN_INTERVAL_TO_SCHEDULE + 1.minute,
        appointment_status_id: cancelled_appointment_status.id,
        appointment_type_id: appointment_type.id,
        provider_id: provider.id,
        patient_id: patient.id,
        practice_id: practice.id }
      expect{ do_request appointment_params }.to change{ Delayed::Job.where(queue: PostAppointmentJob.queue_name).count }.by(2)
      expect(response.status).to eq(200)
      expect(appointment.reload.cancelled?).to eq(true)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:appointment].as_json.to_json).to eq(serializer.represent(Appointment.last).as_json.to_json) 
    end
  end
end
