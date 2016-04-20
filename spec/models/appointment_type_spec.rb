require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  describe "self.mapped_appointment_type_id_for_athena_id" do

    before do
      @well_visit = create(:appointment_type, :well_visit)
      @sick_visit = create(:appointment_type, :sick_visit)
      @follow_up_visit = create(:appointment_type, :follow_up_visit)
      @immunization_visit = create(:appointment_type, :immunization_visit)
      @block = create(:appointment_type, :block)
      @consult = create(:appointment_type, :consult)
      @mappable_well_visit_ids = [9, 21, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 82, 62, 63, 64, 65, 66]
      @other_block_id = 61
    end

    def do_request(athena_id)
      AppointmentType.mapped_appointment_type_id_for_athena_id(athena_id)
    end

    context "existing appointment type" do
      it "returns the existing id" do
        existing_type_ids = AppointmentType.all.pluck(:athena_id)
        existing_type_ids.each { |t| expect(do_request(t)).to eq(t) }
      end
    end

    context "testing server differences" do
      it "returns 11" do
        expect(do_request(11)).to eq(11)
      end
    end

    context "well visit with known mapping" do
      it "returns the well visit type" do
        @mappable_well_visit_ids.each { |t| expect(do_request(t)).to eq(@well_visit.athena_id) }
      end
    end

    context "block type with known mapping" do
      it "returns the block type" do
        expect(do_request(@other_block_id)).to eq(@block.athena_id)
      end
    end

    context "unknown appointment type" do
      it "returns the block type" do
        expect(do_request(1000 + rand(1000))).to eq(@block.athena_id)
      end
    end
  end
end
