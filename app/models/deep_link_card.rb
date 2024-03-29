class DeepLinkCard < ActiveRecord::Base
  acts_as_paranoid

  has_many :card_notifications, as: :card
  has_many :users, through: :card_notifications

  mount_uploader :icon, CardIconUploader
  validates_integrity_of  :icon
  validates_processing_of :icon

  validates :title, :category, :body, :tint_color_hex, presence: true
end
