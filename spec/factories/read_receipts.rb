# == Schema Information
#
# Table name: read_receipts
#
#  id             :integer          not null, primary key
#  message_id     :integer
#  participant_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :read_receipt do
    message_id 1
participant_id "MyString"
  end

end
