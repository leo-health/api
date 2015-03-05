class Message < ActiveRecord::Base
	belongs_to :conversation
	has_many :read_receipts
end
