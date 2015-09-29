class Session < ActiveRecord::Base
  acts_as_token_authenticatable
  acts_as_paranoid

  belongs_to :user

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :user, :authentication_token, presence: true
  validates :authentication_token, uniqueness: {scope: :deleted_at}
end
