class MessagePhoto < ActiveRecord::Base
  mount_uploader :image, MessageUploader
  belongs_to :message

  validates_integrity_of  :image
  validates_processing_of :image
  validates :message, presence: true
end
