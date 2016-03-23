class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{ clinical_staff }, class_name: "User"

  validates :provider, presence: true
end
