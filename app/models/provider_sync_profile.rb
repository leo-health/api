class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{ provider }, class_name: "User"

  validates :provider, presence: true
end
