class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid

  belongs_to :user

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, presence: true
  validates :device_height, :device_width, :device_token, :device_identifier, presence: true, if: :mobile?
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  private

  def mobile?
    [:ios, :android].include?(platform.try(:to_sym))
  end

  def guardian?
    user.has_role? :guardian
  end
end
