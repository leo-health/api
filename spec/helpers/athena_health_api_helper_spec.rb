require 'rails_helper'
require 'athena_health_api_helper'

module Net
  class HTTP
    def self.enable_debug!
      raise "You don't want to do this in anything but development mode!" unless Rails.env == 'development' || Rails.env == 'test'
      class << self
        alias_method :__new__, :new
        def new(*args, &blk)
          instance = __new__(*args, &blk)
          instance.set_debug_output($stderr)
          instance
        end
      end
    end
 
    def self.disable_debug!
      class << self
        alias_method :new, :__new__
        remove_method :__new__
      end
    end

    #Net::HTTP.enable_debug!

  end
end


RSpec.describe AthenaHealthApiHelper, type: :helper do
  deparment_id = ENV["ATHENA_TEST_DEPARTMENT_ID"]
  provider_id = ENV["ATHENA_TEST_PROVIDER_ID"]

  describe "Athena Health Api Helper - " do
    it "get a list of appointment types" do
      res = AthenaHealthApiHelper.get_appointment_types()
      Rails.logger.info(res.to_json)
    end

    it "get a list of appointment reasons" do
      res = AthenaHealthApiHelper.get_appointment_reasons(departmentid: deparment_id, 
        providerid: provider_id)
      Rails.logger.info(res.to_json)
    end

    it "get a list of open appointments" do
      res = AthenaHealthApiHelper.get_open_appointments(departmentid: deparment_id, 
        appointmenttypeid: 1)
      Rails.logger.info(res.to_json)
    end

    it "get a list of booked slots" do
      res = AthenaHealthApiHelper.get_booked_appointments(departmentid: deparment_id, 
        startdate: "01/01/1920", enddate: "01/01/2020")
      Rails.logger.info(res.to_json)
    end
  end
end
