require "athena_health_api"

module GrowthCurvesHelper
  def self.z_percentile
    [
      { z: 0, p: 50 },
      { z: Float::MIN, p: 50 },
      { z: 0.025, p: 49 },
      { z: 0.050, p: 48 },
      { z: 0.075, p: 47 },
      { z: 0.100, p: 46 },
      { z: 0.126, p: 45 },
      { z: 0.151, p: 44 },
      { z: 0.202, p: 42 },
      { z: 0.228, p: 41 },
      { z: 0.253, p: 40 },
      { z: 0.279, p: 39 },
      { z: 0.305, p: 38 },
      { z: 0.332, p: 37 },
      { z: 0.358, p: 36 },
      { z: 0.385, p: 35 },
      { z: 0.412, p: 34 },
      { z: 0.440, p: 33 },
      { z: 0.468, p: 32 },
      { z: 0.496, p: 31 },
      { z: 0.524, p: 30 },
      { z: 0.553, p: 29 },
      { z: 0.583, p: 28 },
      { z: 0.613, p: 27 },
      { z: 0.643, p: 26 },
      { z: 0.674, p: 25 },
      { z: 0.706, p: 24 },
      { z: 0.739, p: 23 },
      { z: 0.772, p: 22 },
      { z: 0.806, p: 21 },
      { z: 0.842, p: 20 },
      { z: 0.878, p: 19 },
      { z: 0.915, p: 18 },
      { z: 0.954, p: 17 },
      { z: 0.994, p: 16 },
      { z: 1.036, p: 15 },
      { z: 1.080, p: 14 },
      { z: 1.126, p: 13 },
      { z: 1.175, p: 12 },
      { z: 1.227, p: 11 },
      { z: 1.282, p: 10 },
      { z: 1.341, p: 9 },
      { z: 1.405, p: 8 },
      { z: 1.476, p: 7 },
      { z: 1.555, p: 6 },
      { z: 1.645, p: 5 },
      { z: 1.751, p: 4 },
      { z: 1.881, p: 3 },
      { z: 2.054, p: 2},
      { z: Float::MAX, p: 1}
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
    days = (date.to_date - dob.to_date).to_i
    entry = WeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end

  def self.height_percentile(sex, dob, date, value)
    days = (date.to_date - dob.to_date).to_i
    entry = HeightGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end

  def self.bmi_percentile(sex, dob, date, value)
    days = (date.to_date - dob.to_date).to_i
    entry = BmiGrowthCurve.where(sex: sex, days: (days-min_days_window)..days).order(:days).last
    return nil unless entry
    z = calculate_z(value, entry.l, entry.m, entry.s)
    calculate_percentile(z)
  end
end
