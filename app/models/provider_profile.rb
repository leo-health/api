class ProviderProfile < ActiveRecord::Base
  belongs_to :provider, ->{where role_id: 5}, class_name: "User"

  validates :provider, presence: true
  validate :provider_identity

  def provider_identity
    errors.add(:provider_id, "must be a provider") unless provider.has_role? :clinical
  end
end
