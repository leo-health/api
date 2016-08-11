class CardNotification < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :card, polymorphic: true
  belongs_to :user
end
