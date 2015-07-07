class ReadReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :participant, class_name: 'User'
end
