class ReadReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :reader, class_name: 'User'

  validates :messages, :reader, presence: true
  validates_uniqueness_of :reader_id, scope: :message_id
end
