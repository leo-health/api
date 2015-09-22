class Avatar < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  belongs_to :owner, polymorphic: true
end
