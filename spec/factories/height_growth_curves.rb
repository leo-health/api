FactoryGirl.define do
  factory :height_growth_curve, :class => 'HeightGrowthCurve' do
    days 0
    sex { [ "M", "F" ].sample }
    l 1
    m 60
    s 0.04
  end

end
