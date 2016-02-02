class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{where('role_id != ?', 4)}, foreign_key: "user_id", class_name: "User"

  validates :staff, presence: true
  # validate :provider_identity

  # def provider_identity
  #   errors.add(:provider_id, "must be a provider") unless provider.has_role? :clinical
  # end
end
