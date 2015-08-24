class ProviderProfie < ActiveRecord::Base
  belongs_to :provider, class_name: "User"

  validates :provider, presence: true
  validate :provider_indentiy

  def provider_indentiy
    errors.add(:provider_id, "must be a provider") unless provider.has_role? :clinical
  end
end
