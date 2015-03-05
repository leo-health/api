FactoryGirl.define do
  factory :message do
    sender_id 1
conversation_id 1
body "MyText"
message_type "MyString"
  end

end
