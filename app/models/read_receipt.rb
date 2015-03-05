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

class ReadReceipt < ActiveRecord::Base
	belongs_to :message
end
