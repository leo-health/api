class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{ where(role: Role.find_by(name: :guardian)) }, class_name: "User"

  validates :provider, presence: true
end
