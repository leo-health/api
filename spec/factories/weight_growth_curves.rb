FactoryGirl.define do
  factory :weight_growth_curve, :class => 'WeightGrowthCurve' do
    days 0
    sex { [ "M", "F" ].sample }
    l 1
    m 5.0
    s 0.04
  end

end
