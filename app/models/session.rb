class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid
  belongs_to :user
  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, presence: true
  validates :device_type, presence: true, if: :mobile?
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE = {
    'ios' => { 'ContentCards' => '1.4.1' },
    'android' => { 'ContentCards' => '1.4.1' }
  }

  def feature_available?(feature_name)

    supported_platforms = MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE.keys

    if supported_platforms.include?(platform.try(:to_s)) && MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE[platform.to_s].has_key?(feature_name.try(:to_s))
      if client_version.try(:to_s) && (MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE[platform.to_s][feature_name.to_s] <= client_version)
        true
      else
        false
      end
    else
      MIN_SUPPORTED_VERSION_BY_PLATFORM_AND_FEATURE[platform.to_s].has_key?(feature_name.try(:to_s)) ? false : true
    end

  end

  private

  def mobile?
    [:ios, :android].include?(platform.try(:to_sym))
  end
end
