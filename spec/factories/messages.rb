# == Schema Information
#
# Table name: messages
#
#  id                   :integer          not null, primary key
#  sender_id            :integer
#  conversation_id      :integer
#  body                 :text
#  message_type         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  escalated_to         :integer
#  resolve_requested_at :datetime
#  resolved_approved_at :datetime
#  escalated_at         :datetime
#

FactoryGirl.define do
  factory :message do
    sender_id 1
conversation_id 1
body "MyText"
message_type "MyString"
  end

end
