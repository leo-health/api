require 'rails_helper'
require 'growth_curves_helper'

RSpec.describe GrowthCurvesHelper, type: :helper do
  describe "calculate_percentile" do
    it "returns correct percentile" do
      expect(GrowthCurvesHelper.calculate_percentile(-2)).to eq(3)
      expect(GrowthCurvesHelper.calculate_percentile(-1.8)).to eq(5)
      expect(GrowthCurvesHelper.calculate_percentile(-1.4)).to eq(10)
      expect(GrowthCurvesHelper.calculate_percentile(-1.1)).to eq(15)
      expect(GrowthCurvesHelper.calculate_percentile(-1)).to eq(25)
      expect(GrowthCurvesHelper.calculate_percentile(-0.5)).to eq(50)
      expect(GrowthCurvesHelper.calculate_percentile(0.5)).to eq(50)
      expect(GrowthCurvesHelper.calculate_percentile(1)).to eq(75)
      expect(GrowthCurvesHelper.calculate_percentile(1.1)).to eq(85)
      expect(GrowthCurvesHelper.calculate_percentile(1.4)).to eq(90)
      expect(GrowthCurvesHelper.calculate_percentile(1.8)).to eq(95)
      expect(GrowthCurvesHelper.calculate_percentile(2)).to eq(97)
    end
  end
end
