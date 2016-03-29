require "athena_health_api"

module GrowthCurvesHelper
  def self.z_percentile
    [
      { z: 0, p: 50 },
      { z: 0.674, p: 50 },
      { z: 1.036, p: 25 },
      { z: 1.282, p: 15 },
      { z: 1.645, p: 10 },
      { z: 1.881, p: 5 },
      { z: Float::MAX, p: 3 }
    ]
  end

  def self.lbs_to_kg(lbs)
     lbs / (0.00220462 * 1000.0)
  end

  def self.kg_to_lbs(kg)
    self.g_to_lbs(kg / 1000.0)
  end

  def self.g_to_lbs(g)
    g * 0.00220462
  end

  def self.m_to_inches(m)
    m * 39.3701
  end

  def self.cm_to_inches(cm)
    cm * 0.393701
  end

  def self.inches_to_m(inches)
    inches / 39.3701
  end

  def self.celsius_to_fahrenheit(c)
    c * 1.8 + 32.0
  end

  def self.fahrenheit_to_celsius(f)
    (f - 32.0) / 1.8
  end

  def self.min_days_window
    31
  end

  def self.calculate_z(value, l, m, s)
    if l == 0
      Math.log(value/m)/s
    else
      ((value/m)**l - 1)/(l*s)
    end
  end

  def self.calculate_percentile(z)
    res = z_percentile.bsearch { |entry| entry[:z] >= z.abs }
    z >= 0 ? 100 - res[:p] : res[:p]
  end

  def self.weight_percentile(sex, dob, date, value)
    days = (date - dob).to_i/1.day
    entry = WeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end

  def self.height_percentile(sex, dob, date, value)
    days = (date - dob).to_i/1.day
    entry = HeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end

  def self.bmi_percentile(sex, dob, date, value)
    days = (date - dob).to_i/1.day
    entry = BmiGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end
end
