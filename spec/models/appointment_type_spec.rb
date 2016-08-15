require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  describe "self.user_facing_appointment_type_for_athena_id" do

    before do
      @well_visit = create(:appointment_type, :well_visit)
      @sick_visit = create(:appointment_type, :sick_visit)
      @follow_up_visit = create(:appointment_type, :follow_up_visit)
      @immunization_visit = create(:appointment_type, :immunization_visit)
      @consult = create(:appointment_type, :consult)
      @mappable_well_visit_ids = [9, 21, 41, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]
      @other_block_id = 61
    end

    def do_request(athena_id)
      AppointmentType.user_facing_appointment_type_for_athena_id(athena_id)
    end

    context "existing visible appointment type" do
      it "returns the existing visible appointment type" do
        user_facing_appointment_types = AppointmentType.where(hidden: false)
        user_facing_appointment_types.each do |t|
          expect(do_request(t.athena_id)).to eq(t)
        end
      end
    end

    context "testing server differences" do
      it "returns well visit" do
        expect(do_request(11)).to eq(@well_visit)
      end
    end

    context "well visit with known mapping" do
      it "returns the well visit type" do
        @mappable_well_visit_ids.each { |t| expect(do_request(t)).to eq(@well_visit) }
      end
    end

    context "block type 14" do
      it "returns the 'other' type" do
        expect(do_request(14)).to eq(@other)
      end
    end

    context "block type 61" do
      it "returns the 'other' type" do
        expect(do_request(61)).to eq(@other)
      end
    end

    context "unknown appointment type" do
      it "returns the block type" do
        expect(do_request(1000 + rand(1000))).to eq(@other)
      end
    end
  end
end
