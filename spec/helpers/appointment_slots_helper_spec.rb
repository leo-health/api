require 'rails_helper'

RSpec.describe AppointmentSlotsHelper, type: :helper do
  describe "Interval- " do
    let(:i1){AppointmentSlotsHelper::Interval.new(0, 10)}

    describe "#intersects?" do
      context "intervals are not intersect" do
        context "intervals are disjoint" do
          let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

          it "should return false" do
            expect(i1.intersects?(i2)).to be(false)
            expect(i2.intersects?(i1)).to be(false)
          end
        end

        context "intervals are inclusive intersect" do
          let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

          it "should return false" do
            expect(i1.intersects?(i2)).to be(false)
            expect(i2.intersects?(i1)).to be(false)
          end
        end
      end

      context "intervals are intersect" do
        context "intervals are fully inclusive" do
          let(:i2){AppointmentSlotsHelper::Interval.new(2, 8)}

          it "should return true" do
            expect(i1.intersects?(i2)).to be(true)
            expect(i2.intersects?(i1)).to be(true)
          end
        end

        context "intervals are partially inclusive" do
          let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

          it "should return true" do
            expect(i1.intersects?(i2)).to be(true)
            expect(i2.intersects?(i1)).to be(true)
          end
        end
      end
    end


    describe "#intersects_inclusive?" do
      context "intervals are not intersects_inclusive" do
        context "intervals are fully disjoint" do
          let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

          it "should return false" do
            expect(i1.intersects_inclusive?(i2)).to be(false)
            expect(i2.intersects_inclusive?(i1)).to be(false)
          end
        end
      end

      context "intervals are intersects_inclusive" do
        context "intervals are partially inclusive" do
          let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

          it "should return true" do
            expect(i1.intersects_inclusive?(i2)).to be(true)
            expect(i2.intersects_inclusive?(i1)).to be(true)
          end
        end

        context "intervals are fully inclusive" do
          let(:i2){AppointmentSlotsHelper::Interval.new(2, 8)}

          it "should return true" do
            expect(i1.intersects_inclusive?(i2)).to be(true)
            expect(i2.intersects_inclusive?(i1)).to be(true)
          end
        end

        context "intervals have single common value" do
          let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

          it "should return true" do
            expect(i1.intersects_inclusive?(i2)).to be(true)
            expect(i2.intersects_inclusive?(i1)).to be(true)
          end
        end
      end
    end

    describe "#+" do
      let(:joined_interval){AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 20) ])}

      context "intervals are disjoint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

        it "should combine the two intervals seperately" do
          expect(i1+i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1, i2 ]))
          expect(i2+i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1, i2 ]))
        end
      end

      context "intervals are partially intersect" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should join the two interval" do
          expect(i1+i2).to eq(joined_interval)
          expect(i2+i1).to eq(joined_interval)
        end
      end

      context "one interval is a subset of the other" do
        let(:i2){AppointmentSlotsHelper::Interval.new(2, 8)}

        it "should return the larger interval" do
          expect(i1+i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 10) ]))
          expect(i2+i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 10) ]))
        end
      end

      context "intervals have single common value" do
        let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

        it "should join the two interval" do
          expect(i1+i2).to eq(joined_interval)
          expect(i2+i1).to eq(joined_interval)
        end
      end
    end

    describe "#-" do
      context "two intervals are disjoint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

        it "should return the subtractor itself" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1 ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i2 ]))
        end
      end

      context "two intervals are partially joint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should subtract the joint from subtractor" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 9) ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(10, 20) ]))
        end
      end

      context "two intervals are fully joint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(2, 8)}

        it "should subtract the joint" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 2), AppointmentSlotsHelper::Interval.new(8, 10) ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ ]))
        end
      end

      context "intervals have single common value" do
        let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

        it "should return the subtractor itself" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1 ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i2 ]))
        end
      end
    end

    describe "#intersect" do
      context "two intervals are disjoint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

        it "should return nil" do
          expect(i1.intersect(i2)).to eq(nil)
          expect(i2.intersect(i1)).to eq(nil)
        end
      end

      context "two intervals are partially joint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should return the joint" do
          expect(i1.intersect(i2)).to eq(AppointmentSlotsHelper::Interval.new(9, 10))
          expect(i2.intersect(i1)).to eq(AppointmentSlotsHelper::Interval.new(9, 10))
        end
      end

      context "two intervals are fully joint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(2, 8)}

        it "should return the subset" do
          expect(i1.intersect(i2)).to eq(AppointmentSlotsHelper::Interval.new(2, 8))
          expect(i2.intersect(i1)).to eq(AppointmentSlotsHelper::Interval.new(2, 8))
        end
      end

      context "intervals have single common value" do
        let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

        it "should return nil" do
          expect(i1.intersect(i2)).to eq(nil)
          expect(i2.intersect(i1)).to eq(nil)
        end
      end
    end

    describe "#empty?" do
      let(:empty_interval_first){AppointmentSlotsHelper::Interval.new(10, 10)}
      let(:empty_interval_second){AppointmentSlotsHelper::Interval.new(11, 10)}

      context "non empty interval" do
        it "should return false" do
          expect(i1.empty?).to eq(false)
        end
      end

      context "empty interval" do
        it "should return true" do
          expect(empty_interval_first.empty?).to eq(true)
          expect(empty_interval_second.empty?).to eq(true)
        end
      end
    end
  end

  describe "DiscreteIntervals- " do
    it "#+" do
      added = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(added).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 20), AppointmentSlotsHelper::Interval.new(30, 40) ]))
    end

    it "#-" do
      added = AppointmentSlotsHelper::Interval.new(0, 40) - AppointmentSlotsHelper::Interval.new(30, 50) - AppointmentSlotsHelper::Interval.new(5, 15)
      expect(added).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 5), AppointmentSlotsHelper::Interval.new(15, 30) ]))
    end

    it "#intersects?" do
      di1 = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersects?(di2)).to be(false)
      expect(di2.intersects?(di1)).to be(false)

      di1 = AppointmentSlotsHelper::Interval.new(0, 11) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersects?(di2)).to be(true)
      expect(di2.intersects?(di1)).to be(true)
    end

    it "#intersects_inclusive" do
      di1 = AppointmentSlotsHelper::Interval.new(0, 9) + AppointmentSlotsHelper::Interval.new(21, 29)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersects_inclusive?(di2)).to be(false)
      expect(di2.intersects_inclusive?(di1)).to be(false)

      di1 = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersects_inclusive?(di2)).to be(true)
      expect(di2.intersects_inclusive?(di1)).to be(true)
    end

    it "#intersect" do
      di1 = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersect(di2)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new())
      expect(di2.intersect(di1)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new())

      di1 = AppointmentSlotsHelper::Interval.new(0, 11) + AppointmentSlotsHelper::Interval.new(20, 31)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersect(di2)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new(
        [AppointmentSlotsHelper::Interval.new(10, 11), AppointmentSlotsHelper::Interval.new(30, 31)]))
      expect(di2.intersect(di1)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new(
        [AppointmentSlotsHelper::Interval.new(10, 11), AppointmentSlotsHelper::Interval.new(30, 31)]))
    end

    it "#intersecting" do
      di1 = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersecting(di2)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new())
      expect(di2.intersecting(di1)).to eq(AppointmentSlotsHelper::DiscreteIntervals.new())

      di1 = AppointmentSlotsHelper::Interval.new(0, 11) + AppointmentSlotsHelper::Interval.new(20, 31)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersecting(di2)).to eq(di1)
      expect(di2.intersecting(di1)).to eq(di2)
    end

    it "#intersecting_inclusive" do
      di1 = AppointmentSlotsHelper::Interval.new(0, 10) + AppointmentSlotsHelper::Interval.new(20, 30)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersecting_inclusive(di2)).to eq(di1)
      expect(di2.intersecting_inclusive(di1)).to eq(di2)

      di1 = AppointmentSlotsHelper::Interval.new(0, 11) + AppointmentSlotsHelper::Interval.new(20, 31)
      di2 = AppointmentSlotsHelper::Interval.new(10, 20) + AppointmentSlotsHelper::Interval.new(30, 40)
      expect(di1.intersecting_inclusive(di2)).to eq(di1)
      expect(di2.intersecting_inclusive(di1)).to eq(di2)
    end
  end

  describe "OpenSlotsProcessor" do
    let(:future_appointment_status){build(:appointment_status, :future)}
    let(:date){Date.today}
    let(:osp){AppointmentSlotsHelper::OpenSlotsProcessor.new}
    let!(:schedule){create( :provider_schedule,
                            monday_start_time: "9:00",
                            monday_end_time: "17:00",
                            tuesday_start_time: "9:00",
                            tuesday_end_time: "17:00",
                            wednesday_start_time: "9:00",
                            wednesday_end_time: "17:00",
                            thursday_start_time: "9:00",
                            thursday_end_time: "17:00",
                            friday_start_time: "9:00",
                            friday_end_time: "17:00",
                            saturday_start_time: "9:00",
                            saturday_end_time: "17:00",
                            sunday_start_time: "9:00",
                            sunday_end_time: "17:00" )}

    let!(:additional_availability){create( :provider_additional_availability, athena_provider_id: 1,
                                           start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "17:00").to_s).in_time_zone,
                                           end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "20:00").to_s).in_time_zone )}

    let!(:leaves){create(:provider_leave, athena_provider_id: 1,
                         start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "09:00").to_s).in_time_zone,
                         end_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "12:00").to_s).in_time_zone)}

    let!(:appointment){create(:appointment, provider_id: 1, appointment_status: future_appointment_status,
                              start_datetime: DateTime.parse(Time.zone.parse(date.inspect + " " + "14:00").to_s).in_time_zone,
                              duration: 20)}

    describe "get_provider_availability" do
      let(:provider_availability){AppointmentSlotsHelper::DiscreteIntervals.new(
          [AppointmentSlotsHelper::Interval.new(osp.to_datetime_str(date, "12:00"), osp.to_datetime_str(date, "14:00")),
           AppointmentSlotsHelper::Interval.new(osp.to_datetime_str(date, "14:20"), osp.to_datetime_str(date, "20:00"))])}

      it "computes availability" do
        expect(osp.get_provider_availability(athena_provider_id: 1, date: date)).to eq(provider_availability)
      end
    end

    describe "get_open_slots" do
      let(:open_slots){[
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "12:00").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "13:00").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "14:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "15:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "16:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "17:20").to_s).in_time_zone, 60),
          AppointmentSlotsHelper::OpenSlot.new(
              DateTime.parse(Time.zone.parse(date.inspect + " " + "18:20").to_s).in_time_zone, 60)
      ]}

      it "returns slots" do
        expect(osp.get_open_slots(athena_provider_id: 1, date: date, durations: [ 60 ])).to eq(open_slots)
      end
    end
  end
end
