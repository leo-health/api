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

class Message < ActiveRecord::Base
	belongs_to :conversation
	has_many :read_receipts
end
