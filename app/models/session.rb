class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid

  belongs_to :user

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, :authentication_token, presence: true
  validates :device_token, presence: true, if: :guardian?
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  private

  def guardian?
    user.has_role? :guardian
  end
end
