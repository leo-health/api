FactoryGirl.define do
  factory :bmi_growth_curve, :class => 'BmiGrowthCurve' do
    days 0
    sex { [ "M", "F" ].sample }
    l 1
    m 13
    s 0.04   
  end

end
