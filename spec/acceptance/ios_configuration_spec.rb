require 'airborne'
require 'rails_helper'

resource "IosConfiguration" do
  get "api/v1/ios_configuration" do
    example "get ios configuration" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
