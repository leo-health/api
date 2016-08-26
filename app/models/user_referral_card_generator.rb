class UserReferralCardGenerator
  def self.update_or_create_referral_card_for_all_guardians
    User.guardians.map { |u| update_or_create_referral_card(u) }
  end

  def self.update_or_create_referral_card(user)
    CardNotification.find_or_create_by(
      user: user,
      card: referral_card
    )
  end

  def self.referral_card
    DeepLinkCard.where(category: :referral).first
  end
end
