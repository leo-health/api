require 'rails_helper'
require 'athena_sync_helper'

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


# Specs in this file have access to a helper object that includes
# the AthenaSyncHelper. For example:
#
# describe AthenaSyncHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AthenaSyncHelper, type: :helper do
  describe "Athena Sync Helper - " do
    it "get a list of appointmenttypes" do
      res = AthenaSyncHelper.get_appointmenttypes(practiceid: 195900, limit: 5)
      Rails.logger.debug(res.to_json)
    end

    it "get a list of patientappointmentreasons" do
      res = AthenaSyncHelper.get_appointmentreasons(practiceid: 195900, departmentid: 145, 
        providerid: 1, limit: 5)
      Rails.logger.debug(res.to_json)
    end

    it "get a list of open slots" do
      res = AthenaSyncHelper.get_open_appointments(practiceid: 195900, departmentid: 1, appointmenttypeid: 1,
        bypassscheduletimechecks: true, ignoreschedulablepermission: true, showfrozenslots: true)

      Rails.logger.debug(res.to_json)
    end

    it "get a list of booked slots" do
      res = AthenaSyncHelper.get_booked_appointments(practiceid: 195900, departmentid: 1, 
        startdate: "01/01/1920", enddate: "01/01/2020", showcancelled: true,
        ignorerestrictions: true)
      Rails.logger.debug(res.to_json)
    end
  end
end
