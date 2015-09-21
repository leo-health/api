require 'rails_helper'

RSpec.describe AppointmentSlotsHelper, type: :helper do
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
end
