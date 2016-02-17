class MessagePhoto < ActiveRecord::Base
  mount_uploader :image, MessageUploader
  belongs_to :message, ->{where('type_name = ?', 'image')}

  validates_integrity_of  :image
  validates_processing_of :image
  validates :message, :image, presence: true
end
