require 'rails_helper'
require 'growth_curves_helper'

RSpec.describe GrowthCurvesHelper, type: :helper do
  describe "GrowthCurvesHelper" do
    describe "calculate_percentile" do
      it "returns correct percentile" do
        expect(GrowthCurvesHelper.calculate_percentile(-1.8)).to eq(3)
        expect(GrowthCurvesHelper.calculate_percentile(-1.6)).to eq(5)
        expect(GrowthCurvesHelper.calculate_percentile(-1.25)).to eq(10)
        expect(GrowthCurvesHelper.calculate_percentile(-1.0)).to eq(15)
        expect(GrowthCurvesHelper.calculate_percentile(-0.65)).to eq(25)
        expect(GrowthCurvesHelper.calculate_percentile(0)).to eq(50)
        expect(GrowthCurvesHelper.calculate_percentile(0.65)).to eq(75)
        expect(GrowthCurvesHelper.calculate_percentile(1.0)).to eq(85)
        expect(GrowthCurvesHelper.calculate_percentile(1.25)).to eq(90)
        expect(GrowthCurvesHelper.calculate_percentile(1.8)).to eq(97)
        expect(GrowthCurvesHelper.calculate_percentile(3)).to eq(99)
      end
    end

    describe "weight_percentile" do
      let!(:entry_0) { create(:weight_growth_curve, days: 0, sex: "M", m: 30) }
      let!(:entry_1) { create(:weight_growth_curve, days: 1, sex: "M", m: 40) }
      let!(:entry_2) { create(:weight_growth_curve, days: 2, sex: "M", m: 50) }

      it "returns correct weight_percentile at 0 days" do
        expect(GrowthCurvesHelper.weight_percentile(entry_0.sex, 0.hours.ago, 0.hours.ago, entry_0.m)).to eq(50)
      end
      it "returns correct weight_percentile at 1 days" do
        expect(GrowthCurvesHelper.weight_percentile(entry_1.sex, 24.hours.ago, 0.hours.ago, entry_1.m)).to eq(50)
      end
      it "returns correct weight_percentile at 2 days" do
        expect(GrowthCurvesHelper.weight_percentile(entry_2.sex, 48.hours.ago, 0.hours.ago, entry_2.m)).to eq(50)
      end
    end

    describe "height_percentile" do
      let!(:entry_0) { create(:height_growth_curve, days: 0, sex: "M", m: 30) }
      let!(:entry_1) { create(:height_growth_curve, days: 1, sex: "M", m: 40) }
      let!(:entry_2) { create(:height_growth_curve, days: 2, sex: "M", m: 50) }

      it "returns correct height_percentile at 0 days" do
        expect(GrowthCurvesHelper.height_percentile(entry_0.sex, 0.hours.ago, 0.hours.ago, entry_0.m)).to eq(50)
      end
      it "returns correct height_percentile at 1 days" do
        expect(GrowthCurvesHelper.height_percentile(entry_1.sex, 24.hours.ago, 0.hours.ago, entry_1.m)).to eq(50)
      end
      it "returns correct height_percentile at 2 days" do
        expect(GrowthCurvesHelper.height_percentile(entry_2.sex, 48.hours.ago, 0.hours.ago, entry_2.m)).to eq(50)
      end
    end

    describe "bmi_percentile" do
      let!(:entry_0) { create(:bmi_growth_curve, days: 0, sex: "M", m: 30) }
      let!(:entry_1) { create(:bmi_growth_curve, days: 1, sex: "M", m: 40) }
      let!(:entry_2) { create(:bmi_growth_curve, days: 2, sex: "M", m: 50) }

      it "returns correct bmi_percentile at 0 days" do
        expect(GrowthCurvesHelper.bmi_percentile(entry_0.sex, 0.hours.ago, 0.hours.ago, entry_0.m)).to eq(50)
      end
      it "returns correct bmi_percentile at 1 days" do
        expect(GrowthCurvesHelper.bmi_percentile(entry_1.sex, 24.hours.ago, 0.hours.ago, entry_1.m)).to eq(50)
      end
      it "returns correct bmi_percentile at 2 days" do
        expect(GrowthCurvesHelper.bmi_percentile(entry_2.sex, 48.hours.ago, 0.hours.ago, entry_2.m)).to eq(50)
      end
    end
  end
end
