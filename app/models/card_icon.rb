class CardIcon < ActiveRecord::Base
  mount_uploader :icon, CardIconUploader

  validates_integrity_of  :icon
  validates_processing_of :icon
  validates :icon, :card_type, presence: true
  validates_uniqueness_of :card_type

  def self.conversation
    find_by_card_type("conversation")
  end

  def self.appointment
    find_by_card_type("appointment")
  end
end
