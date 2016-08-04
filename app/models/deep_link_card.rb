class DeepLinkCard < ActiveRecord::Base
  has_many :card_notifications, as: :card
  has_many :users, through: :card_notifications
end
