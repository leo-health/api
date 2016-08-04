class DeepLinkCard < ActiveRecord::Base
  has_many :card_notifications, as: :card
  has_many :users, through: :card_notifications

  mount_uploader :icon, CardIconUploader
  validates_integrity_of  :icon
  validates_processing_of :icon

  validates :title, :body, :tint_color_hex, presence: true
end
