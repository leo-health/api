require 'rails_helper'
require 'athena_health_api'

describe AthenaHealthAPI do
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

      it "should allow requests to complete under the limit" do
        allow(connection).to receive("request").and_return(Struct.new(:code, :body).new(200, response_body))

        start_time = Time.now
        second_limit = ENV['ATHENA_SECOND_RATE'].to_i
        (second_limit-1).times do
          api_connection.GET("/api/foo")
        end

        expect(Time.now - start_time).to be < 1
      end

      it "should sleep before hitting the limit" do
        allow(connection).to receive("request").and_return(Struct.new(:code, :body).new(200, response_body))

        start_time = Time.now
        second_limit = ENV['ATHENA_SECOND_RATE'].to_i
        second_limit.times do
          api_connection.GET("/api/foo")
        end

        expect(Time.now - start_time).to be >= 1
      end

      it "should not throttle requests on ignore_throttle" do
        allow(connection).to receive("request").and_return(Struct.new(:code, :body).new(200, response_body))

        start_time = Time.now
        second_limit = ENV['ATHENA_SECOND_RATE'].to_i
        second_limit.times do
          api_connection.GET("/api/foo",nil,nil,true)
        end

        expect(Time.now - start_time).to be < 1
      end
    end
  end

  describe "RateLimiter" do
    before do
      subject.reset_counts
    end

    subject { AthenaHealthAPI::RateLimiter.new }

    describe "sleep_time" do
      before { allow(subject).to receive(:sleep_time_day_rate_limit_after_incrementing_call_count).and_return(50)}
      before { allow(subject).to receive(:sleep_time_second_rate_limit_after_incrementing_call_count).and_return(1)}

      it "should return the sleep time needed" do
        expect(subject.sleep_time_after_incrementing_call_count).to eq(50)
      end
    end

    describe "sleep_time_day_rate_limit" do
      context "under day rate limit" do
        it "should return 0 sleep time" do
          expect(subject.sleep_time_day_rate_limit_after_incrementing_call_count).to eq(0)
        end
      end

      context "over day rate limit" do
        before do
          Timecop.freeze(Time.now)
          $redis.flushall
          $redis.set(subject.day_key, subject.per_day_rate_limit)
        end

        after do
          Timecop.return
        end

        it "should return time left till the 24hour cycle end" do
          expect(subject.sleep_time_day_rate_limit_after_incrementing_call_count).to eq(24*60*60)
        end
      end

      context "over day rate limit, but pass previous time cycle" do
        before do
          Timecop.freeze(Time.now)
          $redis.set(subject.day_key, subject.per_day_rate_limit)
        end

        after do
          Timecop.return
        end

        it "should return 0 sleep time" do
          Timecop.travel(Time.now + 2.days)
          expect(subject.sleep_time_day_rate_limit_after_incrementing_call_count).to eq(0)
        end
      end
    end

    describe "#sleep_time_second_rate_limit" do
      context "under second rate limit" do
        it "should return 0 sleep time" do
          expect(subject.sleep_time_second_rate_limit_after_incrementing_call_count).to eq(0)
        end
      end

      context "over second rate limit" do
        before do
          Timecop.freeze(Time.now)
          $redis.set(subject.second_key, subject.per_day_rate_limit)
        end

        after do
          Timecop.return
        end

        it "should return 1 second of sleep time" do
          expect(subject.sleep_time_second_rate_limit_after_incrementing_call_count).to eq(1)
        end
      end
    end
  end
end
