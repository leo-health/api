class Avatar < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  belongs_to :owner, polymorphic: true

  validates_integrity_of  :avatar
  validates_processing_of :avatar
  validates :owner, presence: true
end
