class Session < ActiveRecord::Base
  belongs_to :user

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, :authentication_token, presence: true
  validates_uniqueness_of :authentication_token

  acts_as_token_authenticatable
end
