class ReadReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :reader, class_name: 'User'
end
