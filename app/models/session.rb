class Session < ActiveRecord::Base
  belongs_to :user

  before_validation :set_auth_token, on: [:create, :update]
  validates :user, :authentication_token, presence: true
  validates_uniqueness_of :authentication_token

  acts_as_token_authenticatable

  private

  def set_auth_token
    ensure_authentication_token
  end
end
