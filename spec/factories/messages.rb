# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :integer
#  conversation_id :integer
#  body            :text
#  message_type    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :message do
    sender_id 1
conversation_id 1
body "MyText"
message_type "MyString"
  end

end
