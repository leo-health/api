class CardNotification < ActiveRecord::Base
  belongs_to :card, polymorphic: true
  belongs_to :user
end
