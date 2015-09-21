require 'rails_helper'

RSpec.describe AppointmentSlotsHelper, type: :helper do
  describe "Interval" do
    let(:i1){AppointmentSlotsHelper::Interval.new(0, 10)}

    describe "#intersects?" do
      context "intervals do not intersect" do
        context "intervals are disjoint" do
          let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

          it "should return false" do
            expect(i1.intersects?(i2)).to be(false)
            expect(i2.intersects?(i1)).to be(false)
          end
        end

        context "intervals intersect inclusively" do
          let(:i2){AppointmentSlotsHelper::Interval.new(10, 20)}

          it "should return false" do
            expect(i1.intersects?(i2)).to be(false)
            expect(i2.intersects?(i1)).to be(false)
          end
        end
      end

      context "intervals intersect" do
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

        it "should combine the intervals seperately" do
          expect(i1+i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1, i2 ]))
          expect(i2+i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1, i2 ]))
        end
      end

      context "intervals are partially intersect" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should join the intervals" do
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

        it "should join the intervals" do
          expect(i1+i2).to eq(joined_interval)
          expect(i2+i1).to eq(joined_interval)
        end
      end
    end

    describe "#-" do
      context "intervals are disjoint" do
        let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

        it "should return the subtractor itself" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i1 ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ i2 ]))
        end
      end

      context "intervals partially join" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should subtract the joint from subtractor" do
          expect(i1-i2).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(0, 9) ]))
          expect(i2-i1).to eq(AppointmentSlotsHelper::DiscreteIntervals.new([ AppointmentSlotsHelper::Interval.new(10, 20) ]))
        end
      end

      context "intervals fully join" do
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
      context "intervals disjoin" do
        let(:i2){AppointmentSlotsHelper::Interval.new(11, 20)}

        it "should return nil" do
          expect(i1.intersect(i2)).to eq(nil)
          expect(i2.intersect(i1)).to eq(nil)
        end
      end

      context "intervals partially join" do
        let(:i2){AppointmentSlotsHelper::Interval.new(9, 20)}

        it "should return the joint" do
          expect(i1.intersect(i2)).to eq(AppointmentSlotsHelper::Interval.new(9, 10))
          expect(i2.intersect(i1)).to eq(AppointmentSlotsHelper::Interval.new(9, 10))
        end
      end

      context "intervals fully join" do
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
end
