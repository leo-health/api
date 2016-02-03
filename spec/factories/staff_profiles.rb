FactoryGirl.define do
  factory :staff_profile, :class => 'StaffProfile' do
    association :staff, factory: [:user, :clinical]
    credentials ["M.D.", "M.B.A"]
    specialties [ "pediatrics", "obesity"]
  end
end
