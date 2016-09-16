class GenerateUserReferralCards
  def update_or_create_referral_user_link_preview_for_all_guardians
    User.guardians.map { |u| update_or_create_referral_user_link_preview(u) }
  end

  def update_or_create_referral_user_link_preview(user)
    UserLinkPreview.find_or_create_by(
      user: user,
      owner: user,
      link_preview: referral_link_preview
    )
  end

  private

  def referral_link_preview
    LinkPreview.where(category: :referral).first
  end
end
