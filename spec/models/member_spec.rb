require 'rails_helper'

RSpec.describe Member, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:booked_appointments).class_name('Appointment').with_foreign_key('booked_by_id') }
  end
end
