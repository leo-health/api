require "athena_health_api"

module GrowthCurvesHelper
  def self.z_percentile
    [
      { :z => 0, :p => 50 },
      { :z => 0.674, :p => 50 },
      { :z => 1.036, :p => 25 },
      { :z => 1.282, :p => 15 },
      { :z => 1.645, :p => 10 },
      { :z => 1.881, :p => 5 },
      { :z => Float::MAX, :p => 3 }
    ]
  end

  def self.min_days_window
    31
  end

  def self.calculate_z(value, l, m, s)
    if l == 0
      ((value/m)**l - 1)/(l*s)
    else
      Math.log(value/m)/s
    end
  end

  def self.calculate_percentile(z)
    res = z_percentile.bsearch { |entry| entry[:z] >= z.abs }
    z >= 0 ? 100 - res[:p] : res[:p]
  end

  def self.weight_percentile(sex, dob, date, value)
    days = (date - dob).to_i
    entry = WeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return 0 unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end

  def self.height_percentile(sex, dob, date, value)
    days = (date - dob).to_i
    entry = HeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return 0 unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end
end
