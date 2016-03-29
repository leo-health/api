require 'rails_helper'
require 'athena_health_api'

RSpec.describe AthenaHealthAPI, type: :helper do
  describe "Athena Health Api - " do
    let(:connection) { double("connection") }
    let(:api_connection) { AthenaHealthAPI::Connection.new("version", "key", "secret", "practice_id") }
    let(:response_body) { %q([{ "date": "04\/18\/2009",
                                "appointmentid": "1000",
                                "departmentid": "1",
                                "appointmenttype": "Lab Work",
                                "providerid": "21",
                                "starttime": "15:25",
                                "appointmentstatus": "o",
                                "duration": "15",
                                "appointmenttypeid": "5",
                                "patientappointmenttypename": "Lab Work"
                                }])
                         }

    describe "connection" do
      before { 
        api_connection.instance_variable_set(:@token, "") 
        api_connection.instance_variable_set(:@connection, connection)
      }

      it "should throttle requests" do
        allow(connection).to receive("request").and_return(Struct.new(:code, :body).new(200, response_body))

        sleep(AthenaHealthAPI.configuration.effective_min_request_interval)

        start_time = Time.now

        2.times do
          api_connection.GET("/api/foo")
        end

        expect(Time.now - start_time).to be >= AthenaHealthAPI.configuration.effective_min_request_interval
      end

      it "should not throttle requests on ignore_throttle" do
        allow(connection).to receive("request").and_return(Struct.new(:code, :body).new(200, response_body))

        sleep(AthenaHealthAPI.configuration.effective_min_request_interval)

        start_time = Time.now

        2.times do
          api_connection.GET("/api/foo", nil, nil, true)
        end

        expect(Time.now - start_time).to be < AthenaHealthAPI.configuration.effective_min_request_interval
      end
    end
  end
end
