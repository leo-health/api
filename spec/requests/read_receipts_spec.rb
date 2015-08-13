require 'airborne'
require 'rails_helper'

#TODO add the spec here after merge develop in

describe Leo::V1::ReadReceipts do
  describe "POST /api/v1/read_receipts" do
    def do_request
      post "/api/v1/read_receipts"
    end

    it "should create read receipt for a message" do

    end
  end
end
