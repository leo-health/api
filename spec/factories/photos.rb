FactoryGirl.define do
  factory :photo do
    image ""
    taken_at DateTime.now
  end
end
