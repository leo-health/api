class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{where role_id: 5}, class_name: "User"

  validates :provider, presence: true
end
