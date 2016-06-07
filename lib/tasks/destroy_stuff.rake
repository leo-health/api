namespace :destroy do
  desc 'back fill vendor_id on user'
  task growth_curve: :environment do
    HeightGrowthCurve.destroy_all
    WeightGrowthCurve.destroy_all
    BmiGrowthCurve.destroy_all
  end
end
