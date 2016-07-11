class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid
  belongs_to :user
  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, presence: true
  validates :device_type, :device_token, presence: true, if: :mobile?
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }
  scope :ios, ->{ where.not(client_version: nil) }
  scope :testflight, ->{ where("created_at < ?", Time.new(2016,6,22)) }

  EXPIRATION_PERIOD = 7.days

  def expired?
    expiration_date < Time.now
  end

  def expiration_date
    created_at + EXPIRATION_PERIOD
  end

  private

  def mobile?
    [:ios, :android].include?(platform.try(:to_sym))
  end

  def guardian?
    user.has_role? :guardian
  end
end
