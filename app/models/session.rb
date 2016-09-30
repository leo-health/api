class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid
  belongs_to :user
  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, presence: true
  validates :device_type, presence: true, if: :mobile?
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE = {
    ContentCards: {
      ios: '1.4.1',
      android: '1.4.1'
    }
  }

  def feature_available?(feature_name)
    versioned_feature = MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE[feature_name.to_sym]
    return true unless versioned_feature
    return false unless client_version && platform
    return false unless min_version = versioned_feature[platform.to_sym]
    min_version <= client_version
  end

  private

  def mobile?
    [:ios, :android].include?(platform.try(:to_sym))
  end
end
